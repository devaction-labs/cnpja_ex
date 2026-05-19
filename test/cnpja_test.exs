defmodule CnpjaTest do
  use ExUnit.Case, async: true
  use Cnpja.BypassHelpers

  defp office_fixture do
    %{
      "taxId" => "37335118000180",
      "alias" => "EMPRESA EXEMPLO",
      "founded" => "2010-01-01",
      "head" => true,
      "status" => %{"id" => 2, "text" => "Ativa"},
      "address" => %{
        "street" => "Rua Exemplo",
        "number" => "100",
        "district" => "Centro",
        "city" => "São Paulo",
        "state" => "SP",
        "zip" => "01310100"
      },
      "phones" => [%{"area" => "11", "number" => "999999999"}],
      "emails" => [%{"address" => "contato@exemplo.com.br", "domain" => "exemplo.com.br"}],
      "registrations" => [],
      "mainActivity" => %{"id" => 6201, "text" => "Desenvolvimento de software"},
      "sideActivities" => [],
      "updated" => "2024-01-01T00:00:00.000Z"
    }
  end

  defp company_fixture do
    %{
      "id" => "37335118",
      "name" => "EMPRESA EXEMPLO LTDA",
      "equity" => 100_000,
      "nature" => %{"id" => 2062, "text" => "Sociedade Empresária Limitada"},
      "size" => %{"id" => 1, "text" => "Micro Empresa"},
      "members" => [],
      "offices" => [],
      "simples" => nil,
      "simei" => nil
    }
  end

  describe "get_credit/1" do
    test "returns credit struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/credit", 200, %{"perpetual" => 1000, "transient" => 500})

      assert {:ok, %Cnpja.Credit{perpetual: 1000, transient: 500}} =
               Cnpja.get_credit(base_url: base_url(bypass))
    end

    test "returns error on 401", %{bypass: bypass} do
      stub(bypass, "GET", "/credit", 401, %{"message" => "Invalid API key"})

      assert {:error, %Cnpja.Error{status: 401, message: "Invalid API key"}} =
               Cnpja.get_credit(base_url: base_url(bypass))
    end
  end

  describe "get_zip/2" do
    test "returns zip struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/zip/01310100", 200, %{
        "code" => "01310100",
        "street" => "Avenida Paulista",
        "city" => "São Paulo",
        "state" => "SP"
      })

      assert {:ok, %Cnpja.Zip{code: "01310100", city: "São Paulo", state: "SP"}} =
               Cnpja.get_zip("01310100", base_url: base_url(bypass))
    end

    test "returns error on 404", %{bypass: bypass} do
      stub(bypass, "GET", "/zip/00000000", 404, %{"message" => "CEP não encontrado"})

      assert {:error, %Cnpja.Error{status: 404}} =
               Cnpja.get_zip("00000000", base_url: base_url(bypass))
    end
  end

  describe "get_office/2" do
    test "returns office struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 200, office_fixture())

      assert {:ok, %Cnpja.Office{tax_id: "37335118000180", alias: "EMPRESA EXEMPLO"}} =
               Cnpja.get_office("37335118000180", base_url: base_url(bypass))
    end

    test "parses status label", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 200, office_fixture())

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert %Cnpja.Label{id: 2, text: "Ativa"} = office.status
    end

    test "parses address", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 200, office_fixture())

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert %Cnpja.Address{city: "São Paulo", state: "SP", zip: "01310100"} = office.address
    end

    test "parses phones list", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 200, office_fixture())

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert [%Cnpja.Phone{area: "11", number: "999999999"}] = office.phones
    end

    test "parses main activity", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 200, office_fixture())

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert %Cnpja.Activity{id: 6201} = office.main_activity
    end

    test "returns error 429 with credit info", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 429, %{
        "message" => "Insufficient credits",
        "required" => 5,
        "remaining" => 2
      })

      assert {:error, %Cnpja.Error{status: 429, required: 5, remaining: 2}} =
               Cnpja.get_office("37335118000180", base_url: base_url(bypass))
    end

    test "returns error 400 with constraints", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/00000000000000", 400, %{
        "message" => "Validation failed",
        "constraints" => ["taxId must be a valid CNPJ"]
      })

      assert {:error, %Cnpja.Error{status: 400, constraints: ["taxId must be a valid CNPJ"]}} =
               Cnpja.get_office("00000000000000", base_url: base_url(bypass))
    end
  end

  describe "get_office_map/2" do
    test "returns binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/offices/37335118000180/map", 200, <<1, 2, 3>>)

      assert {:ok, <<1, 2, 3>>} =
               Cnpja.get_office_map("37335118000180", base_url: base_url(bypass))
    end
  end

  describe "get_office_street_view/2" do
    test "returns binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/offices/37335118000180/street", 200, <<4, 5, 6>>)

      assert {:ok, <<4, 5, 6>>} =
               Cnpja.get_office_street_view("37335118000180", base_url: base_url(bypass))
    end
  end

  describe "search_offices/1" do
    test "returns paginated search result", %{bypass: bypass} do
      stub(bypass, "GET", "/offices", 200, %{
        "count" => 1,
        "limit" => 10,
        "next" => nil,
        "records" => [office_fixture()]
      })

      assert {:ok, %Cnpja.OfficeSearch{count: 1, records: [%Cnpja.Office{}]}} =
               Cnpja.search_offices(base_url: base_url(bypass))
    end
  end

  describe "get_company/2" do
    test "returns company struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/companies/37335118", 200, company_fixture())

      assert {:ok, %Cnpja.Company{id: "37335118", name: "EMPRESA EXEMPLO LTDA"}} =
               Cnpja.get_company("37335118", base_url: base_url(bypass))
    end

    test "parses nature and size labels", %{bypass: bypass} do
      stub(bypass, "GET", "/companies/37335118", 200, company_fixture())

      {:ok, company} = Cnpja.get_company("37335118", base_url: base_url(bypass))
      assert %Cnpja.Label{id: 2062} = company.nature
      assert %Cnpja.Label{id: 1} = company.size
    end
  end

  describe "get_person/2" do
    test "returns person struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/persons/abc123", 200, %{
        "id" => "abc123",
        "type" => "NATURAL",
        "name" => "FULANO DE TAL",
        "membership" => []
      })

      assert {:ok, %Cnpja.Person{id: "abc123", name: "FULANO DE TAL", type: "NATURAL"}} =
               Cnpja.get_person("abc123", base_url: base_url(bypass))
    end
  end

  describe "search_persons/1" do
    test "returns paginated search result", %{bypass: bypass} do
      stub(bypass, "GET", "/persons", 200, %{
        "count" => 0,
        "limit" => 10,
        "next" => nil,
        "records" => []
      })

      assert {:ok, %Cnpja.PersonSearch{count: 0, records: []}} =
               Cnpja.search_persons(base_url: base_url(bypass))
    end
  end

  describe "get_rfb/2" do
    test "returns rfb struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/rfb/37335118000180", 200, Map.put(office_fixture(), "members", []))

      assert {:ok, %Cnpja.Rfb{tax_id: "37335118000180", members: []}} =
               Cnpja.get_rfb("37335118000180", base_url: base_url(bypass))
    end
  end

  describe "get_rfb_certificate/2" do
    test "returns pdf binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/rfb/37335118000180/certificate", 200, "%PDF-1.4")

      assert {:ok, "%PDF-1.4"} =
               Cnpja.get_rfb_certificate("37335118000180", base_url: base_url(bypass))
    end
  end

  describe "get_simples/2" do
    test "returns simples struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/simples/37335118000180", 200, %{
        "taxId" => "37335118000180",
        "updated" => "2024-01-01T00:00:00.000Z",
        "simples" => %{"optant" => false, "since" => nil, "history" => []},
        "simei" => nil
      })

      assert {:ok, %Cnpja.Simples{tax_id: "37335118000180"}} =
               Cnpja.get_simples("37335118000180", base_url: base_url(bypass))
    end
  end

  describe "get_simples_certificate/2" do
    test "returns pdf binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/simples/37335118000180/certificate", 200, "%PDF-1.4")

      assert {:ok, "%PDF-1.4"} =
               Cnpja.get_simples_certificate("37335118000180", base_url: base_url(bypass))
    end
  end

  describe "get_ccc/3" do
    test "returns ccc struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/ccc/37335118000180/SP", 200, %{
        "taxId" => "37335118000180",
        "updated" => "2024-01-01T00:00:00.000Z",
        "name" => "EMPRESA EXEMPLO LTDA",
        "originState" => "SP",
        "registrations" => []
      })

      assert {:ok, %Cnpja.Ccc{tax_id: "37335118000180", origin_state: "SP"}} =
               Cnpja.get_ccc("37335118000180", "SP", base_url: base_url(bypass))
    end
  end

  describe "get_ccc_certificate/2" do
    test "returns pdf binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/ccc/37335118000180/certificate", 200, "%PDF-1.4")

      assert {:ok, "%PDF-1.4"} =
               Cnpja.get_ccc_certificate("37335118000180", base_url: base_url(bypass))
    end
  end

  describe "get_suframa/2" do
    test "returns suframa struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/suframa/37335118000180", 200, %{
        "taxId" => "37335118000180",
        "number" => "10123456",
        "name" => "EMPRESA EXEMPLO LTDA",
        "approved" => "2010-01-01",
        "status" => %{"id" => 1, "text" => "Ativo"},
        "incentives" => []
      })

      assert {:ok, %Cnpja.Suframa{tax_id: "37335118000180", number: "10123456"}} =
               Cnpja.get_suframa("37335118000180", base_url: base_url(bypass))
    end
  end

  describe "get_suframa_certificate/2" do
    test "returns pdf binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/suframa/37335118000180/certificate", 200, "%PDF-1.4")

      assert {:ok, "%PDF-1.4"} =
               Cnpja.get_suframa_certificate("37335118000180", base_url: base_url(bypass))
    end
  end

  describe "error handling" do
    test "returns generic error on 503", %{bypass: bypass} do
      stub(bypass, "GET", "/credit", 503, %{"message" => "Service unavailable"})

      assert {:error, %Cnpja.Error{status: 503, message: "Service unavailable"}} =
               Cnpja.get_credit(base_url: base_url(bypass))
    end

    test "returns network error when server is unreachable" do
      Application.put_env(:cnpja_ex, :api_key, "test-key")

      assert {:error, %Cnpja.Error{status: 0}} =
               Cnpja.get_credit(base_url: "http://localhost:1")
    end
  end
end
