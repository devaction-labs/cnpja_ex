defmodule CnpjaTest do
  use ExUnit.Case, async: true
  use Cnpja.BypassHelpers

  defp address_fixture do
    %{
      "street" => "Rua Exemplo",
      "number" => "100",
      "district" => "Centro",
      "city" => "São Paulo",
      "state" => "SP",
      "zip" => "01310100"
    }
  end

  defp office_fixture do
    %{
      "taxId" => "37335118000180",
      "alias" => "EMPRESA EXEMPLO",
      "founded" => "2010-01-01",
      "head" => true,
      "statusDate" => "2010-01-01",
      "status" => %{"id" => 2, "text" => "Ativa"},
      "reason" => nil,
      "specialDate" => nil,
      "special" => nil,
      "address" => address_fixture(),
      "phones" => [%{"area" => "11", "number" => "999999999"}],
      "emails" => [%{"address" => "contato@exemplo.com.br", "domain" => "exemplo.com.br"}],
      "registrations" => [
        %{
          "number" => "123456789",
          "state" => "SP",
          "enabled" => true,
          "statusDate" => "2024-01-01",
          "status" => %{"id" => 1, "text" => "Habilitado"},
          "type" => %{"id" => 1, "text" => "IE Normal"}
        }
      ],
      "mainActivity" => %{
        "id" => 6201,
        "text" => "Desenvolvimento de software",
        "performed" => true
      },
      "sideActivities" => [],
      "updated" => "2024-01-01T00:00:00.000Z"
    }
  end

  defp company_fixture do
    %{
      "id" => 37_335_118,
      "name" => "EMPRESA EXEMPLO LTDA",
      "equity" => 100_000.0,
      "nature" => %{"id" => 2062, "text" => "Sociedade Empresária Limitada"},
      "size" => %{"id" => 1, "acronym" => "ME", "text" => "Micro Empresa"},
      "jurisdiction" => "SP",
      "members" => [],
      "offices" => [],
      "simples" => nil,
      "simei" => nil
    }
  end

  defp company_ref_fixture do
    Map.drop(company_fixture(), ["offices"])
  end

  defp suframa_fixture do
    %{
      "taxId" => "37335118000180",
      "number" => "10123456",
      "name" => "EMPRESA EXEMPLO LTDA",
      "since" => "2010-01-01",
      "head" => true,
      "approved" => true,
      "approvalDate" => "2010-06-01",
      "updated" => "2024-01-01T00:00:00.000Z",
      "status" => %{"id" => 1, "text" => "Ativo"},
      "nature" => %{"id" => 2062, "text" => "Sociedade Empresária Limitada"},
      "address" => address_fixture(),
      "mainActivity" => %{"id" => 6201, "text" => "Desenvolvimento de software"},
      "sideActivities" => [],
      "phones" => [],
      "emails" => [],
      "incentives" => [
        %{
          "tribute" => "IPI",
          "benefit" => "Isenção",
          "purpose" => "Comercialização",
          "basis" => "Lei 123/2006"
        }
      ]
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

    test "returns error on 503", %{bypass: bypass} do
      stub(bypass, "GET", "/credit", 503, %{"message" => "Service unavailable"})

      assert {:error, %Cnpja.Error{status: 503, message: "Service unavailable"}} =
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
      stub(bypass, "GET", "/zip/00000000", 404, %{"message" => "CEP not found"})

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

    test "parses status_date", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 200, office_fixture())

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert office.status_date == "2010-01-01"
    end

    test "parses reason as nil when absent", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 200, office_fixture())

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert office.reason == nil
    end

    test "parses reason label when present", %{bypass: bypass} do
      fixture = Map.put(office_fixture(), "reason", %{"id" => 1, "text" => "Extinção"})
      stub(bypass, "GET", "/offices/37335118000180", 200, fixture)

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert %Cnpja.Label{id: 1, text: "Extinção"} = office.reason
    end

    test "parses special and special_date when present", %{bypass: bypass} do
      fixture =
        office_fixture()
        |> Map.put("special", %{"id" => 1, "text" => "Zona Franca"})
        |> Map.put("specialDate", "2020-01-01")

      stub(bypass, "GET", "/offices/37335118000180", 200, fixture)

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert %Cnpja.Label{id: 1, text: "Zona Franca"} = office.special
      assert office.special_date == "2020-01-01"
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

    test "parses emails list", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 200, office_fixture())

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))

      assert [%Cnpja.Email{address: "contato@exemplo.com.br", domain: "exemplo.com.br"}] =
               office.emails
    end

    test "parses main activity with performed field", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 200, office_fixture())

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert %Cnpja.Activity{id: 6201, performed: true} = office.main_activity
    end

    test "parses state registrations", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/37335118000180", 200, office_fixture())

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))

      assert [
               %Cnpja.StateRegistration{
                 number: "123456789",
                 state: "SP",
                 enabled: true,
                 status_date: "2024-01-01"
               }
             ] = office.registrations
    end

    test "parses embedded company_ref", %{bypass: bypass} do
      fixture = Map.put(office_fixture(), "company", company_ref_fixture())
      stub(bypass, "GET", "/offices/37335118000180", 200, fixture)

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert %Cnpja.CompanyRef{name: "EMPRESA EXEMPLO LTDA", jurisdiction: "SP"} = office.company
    end

    test "parses embedded company_ref size label with acronym", %{bypass: bypass} do
      fixture = Map.put(office_fixture(), "company", company_ref_fixture())
      stub(bypass, "GET", "/offices/37335118000180", 200, fixture)

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert %Cnpja.SizeLabel{id: 1, acronym: "ME", text: "Micro Empresa"} = office.company.size
    end

    test "parses embedded suframa", %{bypass: bypass} do
      fixture = Map.put(office_fixture(), "suframa", suframa_fixture())
      stub(bypass, "GET", "/offices/37335118000180", 200, fixture)

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert %Cnpja.Suframa{number: "10123456", approved: true, head: true} = office.suframa
    end

    test "returns error 400 with constraints", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/00000000000000", 400, %{
        "message" => "Validation failed",
        "constraints" => ["taxId must be a valid CNPJ"]
      })

      assert {:error, %Cnpja.Error{status: 400, constraints: ["taxId must be a valid CNPJ"]}} =
               Cnpja.get_office("00000000000000", base_url: base_url(bypass))
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

    test "returns error on 404", %{bypass: bypass} do
      stub(bypass, "GET", "/offices/00000000000000", 404, %{"message" => "Not found"})

      assert {:error, %Cnpja.Error{status: 404}} =
               Cnpja.get_office("00000000000000", base_url: base_url(bypass))
    end
  end

  describe "get_office_map/2" do
    test "returns binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/offices/37335118000180/map", 200, <<1, 2, 3>>)

      assert {:ok, <<1, 2, 3>>} =
               Cnpja.get_office_map("37335118000180", base_url: base_url(bypass))
    end

    test "accepts width, height, zoom options", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/offices/37335118000180/map", fn conn ->
        assert conn.query_string =~ "width=640"
        assert conn.query_string =~ "height=480"

        conn
        |> Plug.Conn.put_resp_content_type("image/png")
        |> Plug.Conn.send_resp(200, <<1, 2, 3>>)
      end)

      assert {:ok, _} =
               Cnpja.get_office_map("37335118000180",
                 width: 640,
                 height: 480,
                 base_url: base_url(bypass)
               )
    end
  end

  describe "get_office_street_view/2" do
    test "returns binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/offices/37335118000180/street", 200, <<4, 5, 6>>)

      assert {:ok, <<4, 5, 6>>} =
               Cnpja.get_office_street_view("37335118000180", base_url: base_url(bypass))
    end

    test "accepts fov option", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/offices/37335118000180/street", fn conn ->
        assert conn.query_string =~ "fov=90"

        conn
        |> Plug.Conn.put_resp_content_type("image/jpeg")
        |> Plug.Conn.send_resp(200, <<4, 5, 6>>)
      end)

      assert {:ok, _} =
               Cnpja.get_office_street_view("37335118000180", fov: 90, base_url: base_url(bypass))
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

    test "passes search filters as query params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/offices", fn conn ->
        assert conn.query_string =~ "statusIn=2"
        assert conn.query_string =~ "stateIn=SP"
        assert conn.query_string =~ "simplesOptant=true"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(
          200,
          Jason.encode!(%{"count" => 0, "limit" => 10, "next" => nil, "records" => []})
        )
      end)

      Cnpja.search_offices(
        status_in: "2",
        state_in: "SP",
        simples_optant: true,
        base_url: base_url(bypass)
      )
    end
  end

  describe "get_company/2" do
    test "returns company struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/companies/37335118", 200, company_fixture())

      assert {:ok, %Cnpja.Company{id: 37_335_118, name: "EMPRESA EXEMPLO LTDA"}} =
               Cnpja.get_company("37335118", base_url: base_url(bypass))
    end

    test "parses nature and size labels with acronym", %{bypass: bypass} do
      stub(bypass, "GET", "/companies/37335118", 200, company_fixture())

      {:ok, company} = Cnpja.get_company("37335118", base_url: base_url(bypass))
      assert %Cnpja.Label{id: 2062} = company.nature
      assert %Cnpja.SizeLabel{id: 1, acronym: "ME"} = company.size
    end

    test "parses jurisdiction", %{bypass: bypass} do
      stub(bypass, "GET", "/companies/37335118", 200, company_fixture())

      {:ok, company} = Cnpja.get_company("37335118", base_url: base_url(bypass))
      assert company.jurisdiction == "SP"
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

    test "parses person membership", %{bypass: bypass} do
      stub(bypass, "GET", "/persons/abc123", 200, %{
        "id" => "abc123",
        "type" => "NATURAL",
        "name" => "FULANO DE TAL",
        "membership" => [
          %{
            "since" => "2015-01-01",
            "role" => %{"id" => 49, "text" => "Sócio-Administrador"},
            "company" => %{
              "id" => 37_335_118,
              "name" => "EMPRESA EXEMPLO LTDA",
              "equity" => 100_000.0,
              "nature" => %{"id" => 2062, "text" => "Sociedade Empresária Limitada"},
              "size" => %{"id" => 1, "acronym" => "ME", "text" => "Micro Empresa"},
              "jurisdiction" => "SP"
            },
            "agent" => nil
          }
        ]
      })

      {:ok, person} = Cnpja.get_person("abc123", base_url: base_url(bypass))

      assert [
               %Cnpja.PersonMembership{
                 since: "2015-01-01",
                 role: %Cnpja.Label{id: 49},
                 company: %Cnpja.PersonMembershipCompany{name: "EMPRESA EXEMPLO LTDA"}
               }
             ] = person.membership
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

    test "passes search filters as query params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/persons", fn conn ->
        assert conn.query_string =~ "typeIn=NATURAL"
        assert conn.query_string =~ "nameIn=Fulano"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(
          200,
          Jason.encode!(%{"count" => 0, "limit" => 10, "next" => nil, "records" => []})
        )
      end)

      Cnpja.search_persons(type_in: "NATURAL", name_in: "Fulano", base_url: base_url(bypass))
    end
  end

  describe "get_rfb/2" do
    test "returns rfb struct with all fields", %{bypass: bypass} do
      rfb =
        office_fixture()
        |> Map.put("members", [])
        |> Map.put("name", "EMPRESA EXEMPLO LTDA")
        |> Map.put("equity", 100_000.0)
        |> Map.put("nature", %{"id" => 2062, "text" => "Sociedade Empresária Limitada"})
        |> Map.put("size", %{"id" => 1, "acronym" => "ME", "text" => "Micro Empresa"})
        |> Map.put("jurisdiction", "SP")

      stub(bypass, "GET", "/rfb/37335118000180", 200, rfb)

      {:ok, result} = Cnpja.get_rfb("37335118000180", base_url: base_url(bypass))
      assert result.tax_id == "37335118000180"
      assert result.name == "EMPRESA EXEMPLO LTDA"
      assert result.equity == 100_000.0
      assert result.jurisdiction == "SP"
      assert %Cnpja.SizeLabel{acronym: "ME"} = result.size
      assert result.members == []
    end
  end

  describe "get_rfb_certificate/2" do
    test "returns pdf binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/rfb/37335118000180/certificate", 200, "%PDF-1.4")

      assert {:ok, "%PDF-1.4"} =
               Cnpja.get_rfb_certificate("37335118000180", base_url: base_url(bypass))
    end

    test "passes pages option as query param", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/rfb/37335118000180/certificate", fn conn ->
        assert conn.query_string =~ "pages=REGISTRATION%2CMEMBERS"

        conn
        |> Plug.Conn.put_resp_content_type("application/pdf")
        |> Plug.Conn.send_resp(200, "%PDF-1.4")
      end)

      Cnpja.get_rfb_certificate("37335118000180",
        pages: "REGISTRATION,MEMBERS",
        base_url: base_url(bypass)
      )
    end
  end

  describe "get_simples/2" do
    test "returns simples struct on success", %{bypass: bypass} do
      stub(bypass, "GET", "/simples/37335118000180", 200, %{
        "taxId" => "37335118000180",
        "updated" => "2024-01-01T00:00:00.000Z",
        "simples" => %{
          "optant" => true,
          "since" => "2015-01-01",
          "history" => [%{"from" => "2015-01-01", "until" => nil, "text" => "Optante"}]
        },
        "simei" => nil
      })

      {:ok, simples} = Cnpja.get_simples("37335118000180", base_url: base_url(bypass))
      assert simples.tax_id == "37335118000180"
      assert %Cnpja.SimplesOpt{optant: true, since: "2015-01-01"} = simples.simples
      assert [%Cnpja.SimplesHistory{from: "2015-01-01"}] = simples.simples.history
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
        "registrations" => [
          %{
            "number" => "123456789",
            "state" => "SP",
            "enabled" => true,
            "statusDate" => "2024-01-01",
            "status" => %{"id" => 1, "text" => "Habilitado"},
            "type" => %{"id" => 1, "text" => "IE Normal"}
          }
        ]
      })

      {:ok, ccc} = Cnpja.get_ccc("37335118000180", "SP", base_url: base_url(bypass))
      assert ccc.tax_id == "37335118000180"
      assert ccc.origin_state == "SP"
      assert [%Cnpja.StateRegistration{state: "SP", enabled: true}] = ccc.registrations
    end
  end

  describe "get_ccc_certificate/2" do
    test "returns pdf binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/ccc/37335118000180/certificate", 200, "%PDF-1.4")

      assert {:ok, "%PDF-1.4"} =
               Cnpja.get_ccc_certificate("37335118000180", base_url: base_url(bypass))
    end

    test "passes state option as query param", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/ccc/37335118000180/certificate", fn conn ->
        assert conn.query_string =~ "state=SP"

        conn
        |> Plug.Conn.put_resp_content_type("application/pdf")
        |> Plug.Conn.send_resp(200, "%PDF-1.4")
      end)

      Cnpja.get_ccc_certificate("37335118000180", state: "SP", base_url: base_url(bypass))
    end
  end

  describe "get_suframa/2" do
    test "returns suframa struct with all fields", %{bypass: bypass} do
      stub(bypass, "GET", "/suframa/37335118000180", 200, suframa_fixture())

      {:ok, suframa} = Cnpja.get_suframa("37335118000180", base_url: base_url(bypass))
      assert suframa.tax_id == "37335118000180"
      assert suframa.number == "10123456"
      assert suframa.since == "2010-01-01"
      assert suframa.head == true
      assert suframa.approved == true
      assert suframa.approval_date == "2010-06-01"
      assert %Cnpja.Label{id: 1, text: "Ativo"} = suframa.status
      assert %Cnpja.Address{city: "São Paulo"} = suframa.address
      assert [%Cnpja.SuframaIncentive{tribute: "IPI"}] = suframa.incentives
    end
  end

  describe "get_suframa_certificate/2" do
    test "returns pdf binary on success", %{bypass: bypass} do
      stub_binary(bypass, "GET", "/suframa/37335118000180/certificate", 200, "%PDF-1.4")

      assert {:ok, "%PDF-1.4"} =
               Cnpja.get_suframa_certificate("37335118000180", base_url: base_url(bypass))
    end
  end

  describe "address parsing" do
    test "accepts zip field", %{bypass: bypass} do
      fixture =
        Map.put(office_fixture(), "address", %{
          "zip" => "01310100",
          "city" => "SP",
          "state" => "SP"
        })

      stub(bypass, "GET", "/offices/37335118000180", 200, fixture)

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert office.address.zip == "01310100"
    end

    test "accepts code field as zip alias", %{bypass: bypass} do
      fixture =
        Map.put(office_fixture(), "address", %{
          "code" => "01310100",
          "city" => "SP",
          "state" => "SP"
        })

      stub(bypass, "GET", "/offices/37335118000180", 200, fixture)

      {:ok, office} = Cnpja.get_office("37335118000180", base_url: base_url(bypass))
      assert office.address.zip == "01310100"
    end
  end

  describe "error handling" do
    test "returns network error when server is unreachable" do
      Application.put_env(:cnpja_ex, :api_key, "test-key")

      assert {:error, %Cnpja.Error{status: 0}} =
               Cnpja.get_credit(base_url: "http://localhost:1")
    end
  end
end
