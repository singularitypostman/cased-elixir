defmodule Cased.RequestTest do
  use Cased.TestCase

  describe "run/2" do
    ##
    # GET /policies

    @tag bypass: [fixture: "policies"]
    test "returns policies when provided in the response", %{client: client} do
      assert {:ok, policies} =
               client
               |> Cased.Policy.query()
               |> Cased.Request.run()

      assert 2 == length(policies)

      first_policy = policies |> List.first()

      assert [%Cased.AuditTrail{name: "default"}] = first_policy.audit_trails
    end

    @tag bypass: [fixture: "policies", paginated: true]
    test "returns policies when provided in the response, requested page by page", %{
      client: client
    } do
      for page <- 1..3 do
        policies =
          client
          |> Cased.Policy.query(page: page, per_page: 2)
          |> Cased.Request.run!()

        assert 2 == length(policies)
      end
    end

    ##
    # GET /policies/{policy_id}

    @policy_id "policy_1dQpXoEwVBmRizOgkgZ00NqpT0g"

    @tag bypass: [fixture: "policy"]
    test "returns a policy", %{
      client: client
    } do
      result =
        client
        |> Cased.Policy.get(@policy_id)
        |> Cased.Request.run!()

      assert %Cased.Policy{id: @policy_id} = result
    end

    ##
    # POST /policies

    @tag bypass: [fixture: "policy"]
    test "creates a basic policy", %{
      client: client
    } do
      result =
        client
        |> Cased.Policy.create(
          name: "casedtest",
          description: "A test policy",
          audit_trails: [:casedtest]
        )
        |> Cased.Request.run!()

      assert %Cased.Policy{} = result
    end

    ##
    # PUT /policies/{policy_id}

    @policy_id "policy_STUB"

    @tag bypass: [fixture: "policy"]
    test "updates a basic policy using the ID", %{
      client: client
    } do
      result =
        client
        |> Cased.Policy.update(
          @policy_id,
          name: "casedtest",
          description: "A test policy",
          audit_trails: [:casedtest]
        )
        |> Cased.Request.run!()

      assert %Cased.Policy{} = result
    end

    ##
    # DELETE /policies/{policy_id}

    @policy_id "policy_STUB"

    @tag bypass: [fixture: :empty, status: 204]
    test "deletes a policy by ID", %{
      client: client
    } do
      assert :ok ==
               client
               |> Cased.Policy.delete(@policy_id)
               |> Cased.Request.run!()
    end

    @tag bypass: [fixture: :empty, status: 404]
    test "deletes a policy with a bad ID", %{
      client: client
    } do
      assert_raise Cased.ResponseError, fn ->
        client
        |> Cased.Policy.delete(@policy_id)
        |> Cased.Request.run!()
      end
    end

    ##
    # GET /events

    @tag bypass: [fixture: "events"]
    test "returns events when provided in the response", %{client: client} do
      assert {:ok, events} =
               client
               |> Cased.Event.query()
               |> Cased.Request.run()

      assert 1 == length(events)
    end

    @tag bypass: [fixture: "events", status: 502]
    test "returns error for a bad status", %{client: client} do
      assert {:error, %Cased.ResponseError{response: %{status_code: 502}}} =
               client
               |> Cased.Event.query()
               |> Cased.Request.run()
    end
  end

  describe "run!/2" do
    @tag bypass: [fixture: "events"]
    test "returns events when provided in the response", %{client: client} do
      events =
        client
        |> Cased.Event.query()
        |> Cased.Request.run!()

      assert 1 == length(events)
    end

    @tag bypass: [fixture: "events", paginated: true]
    test "returns events when provided in the response, requested page by page", %{
      client: client
    } do
      for page <- 1..3 do
        events =
          client
          |> Cased.Event.query(page: page, per_page: 2)
          |> Cased.Request.run!()

        assert 2 == length(events)
      end
    end

    @tag bypass: [fixture: "events"]
    test "returns events when explicitly selecting the (default) :transformed response processing strategy",
         %{
           client: client
         } do
      events =
        client
        |> Cased.Event.query()
        |> Cased.Request.run!(response: :transformed)

      assert [%Cased.Event{id: "event_1dT9pc2vFotPWgMCLRmwgGDdeDp"}] = events
    end

    @tag bypass: [fixture: "events"]
    test "returns the decoded JSON when selecting the :decoded response processing strategy", %{
      client: client
    } do
      body =
        client
        |> Cased.Event.query()
        |> Cased.Request.run!(response: :decoded)

      assert Map.has_key?(body, "results")
    end

    @tag bypass: [fixture: "events"]
    test "returns the raw response when selecting the :raw response processing strategy", %{
      client: client
    } do
      assert %Mojito.Response{status_code: 200} =
               client
               |> Cased.Event.query()
               |> Cased.Request.run!(response: :raw)
    end

    @tag bypass: [fixture: "events", status: 502]
    test "raises an exception for a bad status", %{client: client} do
      assert_raise Cased.ResponseError, fn ->
        client
        |> Cased.Event.query()
        |> Cased.Request.run!()
      end
    end

    ##
    # GET /audit_trails/{audit_trail}/events

    @tag bypass: [fixture: "events"]
    test "returns events for a specific audit trail when provided in the response", %{
      client: client
    } do
      events =
        client
        |> Cased.Event.query(audit_trail: :organizations)
        |> Cased.Request.run!()

      assert 1 == length(events)
    end

    ##
    # GET /events/{event_id}

    @event_id "event_1dT9pc2vFotPWgMCLRmwgGDdeDp"

    @tag bypass: [fixture: "event"]
    test "returns an event when requested without an audit trail", %{
      client: client
    } do
      result =
        client
        |> Cased.Event.get(@event_id)
        |> Cased.Request.run!()

      assert %Cased.Event{id: @event_id} = result
    end

    ##
    # GET /audit_trails/{audit_trail}/events/{event_id}

    @tag bypass: [fixture: "event"]
    test "returns an event when requested with an audit trail", %{
      client: client
    } do
      result =
        client
        |> Cased.Event.get(@event_id, audit_trail: :organizations)
        |> Cased.Request.run!()

      assert %Cased.Event{id: @event_id} = result
    end
  end

  describe "stream/1" do
    @tag bypass: [fixture: "events", paginated: true]
    test "returns paginated event records", %{
      client: client
    } do
      events =
        client
        |> Cased.Event.query()
        |> Cased.Request.stream()
        |> Enum.take(3)

      assert 3 == length(events)
    end

    @tag bypass: [fixture: "policies", paginated: true]
    test "returns paginated policy records", %{
      client: client
    } do
      policies =
        client
        |> Cased.Policy.query()
        |> Cased.Request.stream()
        |> Enum.take(5)

      assert 5 == length(policies)
    end
  end
end
