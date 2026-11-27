"""Integration tests: exercise several endpoints together incl. metrics + secret masking."""
import pytest
import app as appmod


@pytest.fixture
def client():
    appmod.app.config["TESTING"] = True
    return appmod.app.test_client()


def test_metrics_reflect_traffic(client):
    before = client.get("/metrics").get_data(as_text=True)
    for _ in range(3):
        client.get("/")
    after = client.get("/metrics").get_data(as_text=True)

    def n(t):
        return int(t.split("app_requests_total ")[1].split()[0])

    assert n(after) >= n(before) + 3


def test_error_injection(client, monkeypatch):
    monkeypatch.setattr(appmod, "ERROR_RATE", 1.0)
    assert client.get("/").status_code == 500


def test_secret_value_never_leaked(client, monkeypatch):
    monkeypatch.delenv("VAULT_ADDR", raising=False)
    monkeypatch.setenv("DB_PASSWORD", "super-secret")
    body = client.get("/secret-check").get_data(as_text=True)
    assert "super-secret" not in body and "********" in body
