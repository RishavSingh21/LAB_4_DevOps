import pytest
import app as appmod


@pytest.fixture
def client():
    appmod.app.config["TESTING"] = True
    return appmod.app.test_client()


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200 and r.get_json()["status"] == "ok"


def test_add(client):
    assert client.get("/add/2/3").get_json()["result"] == 5


def test_index_has_version(client):
    body = client.get("/").get_json()
    assert "version" in body and "color" in body


def test_secret_env_fallback(monkeypatch):
    monkeypatch.delenv("VAULT_ADDR", raising=False)
    monkeypatch.setenv("DB_PASSWORD", "x")
    assert appmod.get_secret("DB_PASSWORD") == ("x", "env")


def test_secret_missing(monkeypatch):
    monkeypatch.delenv("VAULT_ADDR", raising=False)
    monkeypatch.delenv("DB_PASSWORD", raising=False)
    assert appmod.get_secret("DB_PASSWORD") == (None, "none")


def test_secret_from_vault(monkeypatch):
    class R:
        def raise_for_status(self): pass
        def json(self): return {"data": {"data": {"DB_PASSWORD": "from-vault"}}}
    monkeypatch.setenv("VAULT_ADDR", "http://vault:8200")
    monkeypatch.setenv("VAULT_TOKEN", "t")
    monkeypatch.setattr(appmod.requests, "get", lambda *a, **k: R())
    assert appmod.get_secret("DB_PASSWORD") == ("from-vault", "vault")
