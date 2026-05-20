defmodule Cnpja.SharedTest do
  use ExUnit.Case, async: true

  describe "Cnpja.Address.from_map_nullable/1" do
    test "returns nil when given nil" do
      assert nil == Cnpja.Address.from_map_nullable(nil)
    end

    test "parses address map" do
      map = %{"city" => "São Paulo", "state" => "SP", "zip" => "01310100"}

      assert %Cnpja.Address{city: "São Paulo", state: "SP", zip: "01310100"} =
               Cnpja.Address.from_map_nullable(map)
    end
  end

  describe "Cnpja.Activity.from_map_nullable/1" do
    test "returns nil when given nil" do
      assert nil == Cnpja.Activity.from_map_nullable(nil)
    end
  end

  describe "Cnpja.Label.from_map_nullable/1" do
    test "returns nil when given nil" do
      assert nil == Cnpja.Label.from_map_nullable(nil)
    end
  end

  describe "Cnpja.Country.from_map/1 and from_map_nullable/1" do
    test "parses country map" do
      assert %Cnpja.Country{id: 76, name: "Brasil"} =
               Cnpja.Country.from_map(%{"id" => 76, "name" => "Brasil"})
    end

    test "returns nil when given nil" do
      assert nil == Cnpja.Country.from_map_nullable(nil)
    end

    test "parses non-nil country via from_map_nullable" do
      assert %Cnpja.Country{id: 76, name: "Brasil"} =
               Cnpja.Country.from_map_nullable(%{"id" => 76, "name" => "Brasil"})
    end
  end

  describe "Cnpja.SizeLabel.from_map/1 and from_map_nullable/1" do
    test "parses size label map" do
      assert %Cnpja.SizeLabel{id: 1, acronym: "ME", text: "Micro Empresa"} =
               Cnpja.SizeLabel.from_map(%{
                 "id" => 1,
                 "acronym" => "ME",
                 "text" => "Micro Empresa"
               })
    end

    test "returns nil when given nil" do
      assert nil == Cnpja.SizeLabel.from_map_nullable(nil)
    end

    test "parses non-nil size via from_map_nullable" do
      assert %Cnpja.SizeLabel{acronym: "EPP"} =
               Cnpja.SizeLabel.from_map_nullable(%{
                 "id" => 3,
                 "acronym" => "EPP",
                 "text" => "Empresa de Pequeno Porte"
               })
    end
  end

  describe "Cnpja.Agent.from_map/1 and from_map_nullable/1" do
    test "parses agent map" do
      map = %{
        "person" => %{"id" => "p1", "type" => "NATURAL", "name" => "FULANO"},
        "role" => %{"id" => 49, "text" => "Procurador"}
      }

      assert %Cnpja.Agent{role: %Cnpja.Label{id: 49}} = Cnpja.Agent.from_map(map)
    end

    test "returns nil when given nil" do
      assert nil == Cnpja.Agent.from_map_nullable(nil)
    end

    test "parses non-nil agent via from_map_nullable" do
      map = %{
        "person" => %{"id" => "p2", "type" => "NATURAL", "name" => "CICLANO"},
        "role" => %{"id" => 65, "text" => "Representante Legal"}
      }

      assert %Cnpja.Agent{role: %Cnpja.Label{id: 65}} = Cnpja.Agent.from_map_nullable(map)
    end
  end

  describe "Cnpja.PersonRef.from_map/1" do
    test "parses person ref map" do
      map = %{"id" => "abc", "type" => "NATURAL", "name" => "FULANO DE TAL"}

      assert %Cnpja.PersonRef{id: "abc", name: "FULANO DE TAL", type: "NATURAL"} =
               Cnpja.PersonRef.from_map(map)
    end
  end

  describe "Cnpja.Member.from_map/1" do
    test "parses member map" do
      map = %{
        "since" => "2010-01-01",
        "person" => %{"id" => "p1", "type" => "NATURAL", "name" => "FULANO"},
        "role" => %{"id" => 49, "text" => "Sócio-Administrador"},
        "agent" => nil
      }

      assert %Cnpja.Member{since: "2010-01-01", role: %Cnpja.Label{id: 49}} =
               Cnpja.Member.from_map(map)
    end
  end

  describe "Cnpja.SimplesHistory.from_map/1" do
    test "parses simples history map" do
      map = %{"from" => "2015-01-01", "until" => "2020-12-31", "text" => "Optante"}

      assert %Cnpja.SimplesHistory{from: "2015-01-01", until: "2020-12-31", text: "Optante"} =
               Cnpja.SimplesHistory.from_map(map)
    end
  end

  describe "Cnpja.StateRegistration.from_map/1" do
    test "parses state registration map" do
      map = %{
        "number" => "123456789",
        "state" => "SP",
        "enabled" => true,
        "statusDate" => "2024-01-01",
        "status" => %{"id" => 1, "text" => "Habilitado"},
        "type" => nil
      }

      assert %Cnpja.StateRegistration{number: "123456789", state: "SP", enabled: true} =
               Cnpja.StateRegistration.from_map(map)
    end
  end

  describe "Cnpja.SuframaIncentive.from_map/1" do
    test "parses suframa incentive map" do
      map = %{
        "tribute" => "IPI",
        "benefit" => "Isenção",
        "purpose" => "Comercialização",
        "basis" => "Lei 123/2006"
      }

      assert %Cnpja.SuframaIncentive{tribute: "IPI", benefit: "Isenção"} =
               Cnpja.SuframaIncentive.from_map(map)
    end
  end

  describe "Cnpja.Company.from_map_nullable/1" do
    test "returns nil when given nil" do
      assert nil == Cnpja.Company.from_map_nullable(nil)
    end

    test "parses non-nil company via from_map_nullable" do
      map = %{"id" => "37335118", "name" => "EMPRESA LTDA", "members" => [], "offices" => []}

      assert %Cnpja.Company{id: "37335118", name: "EMPRESA LTDA"} =
               Cnpja.Company.from_map_nullable(map)
    end
  end

  describe "Cnpja.Office.from_map_nullable/1" do
    test "returns nil when given nil" do
      assert nil == Cnpja.Office.from_map_nullable(nil)
    end

    test "parses non-nil office via from_map_nullable" do
      map = %{
        "taxId" => "37335118000180",
        "status" => %{"id" => 2, "text" => "Ativa"},
        "address" => %{"city" => "São Paulo", "state" => "SP", "zip" => "01310100"}
      }

      assert %Cnpja.Office{tax_id: "37335118000180"} = Cnpja.Office.from_map_nullable(map)
    end
  end

  describe "Cnpja.Suframa.from_map_nullable/1" do
    test "returns nil when given nil" do
      assert nil == Cnpja.Suframa.from_map_nullable(nil)
    end

    test "parses non-nil suframa via from_map_nullable" do
      map = %{"taxId" => "37335118000180"}

      assert %Cnpja.Suframa{tax_id: "37335118000180"} =
               Cnpja.Suframa.from_map_nullable(map)
    end
  end

  describe "Cnpja.Link.from_map/1" do
    test "parses link map" do
      map = %{"type" => "RFB_CERTIFICATE", "url" => "https://example.com/rfb.pdf"}

      assert %Cnpja.Link{type: "RFB_CERTIFICATE", url: "https://example.com/rfb.pdf"} =
               Cnpja.Link.from_map(map)
    end
  end
end
