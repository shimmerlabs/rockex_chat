defmodule RocketChat.Channel do
  import RocketChat.Utils
  alias RocketChat.API

  @doc """
  Create a channel with the given name.  Options:
  read_only: true/false  (default: false)
  members: array of usernames to add (default empty list)

  API Ref:  https://developer.rocket.chat/api/rest-api/methods/channels/create
  """
  def create(name, opts \\ []) do
    %{
      "name" => name,
      "members" => Keyword.get(opts, :members, []),
      "readOnly" => Keyword.get(opts, :read_only, false)
    }
    |> API.post("v1/channels.create")
    |> decode_success()
  end

  @doc """
  Delete a channel by :id or :name -- one must defined.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/delete
  """
  def delete(name_or_id) when is_list(name_or_id) do
    room_id_or_name(name_or_id)
    |> API.post("v1/channels.delete")
    |> decode_success()
  end

  @doc """
  List all channels

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/list
  """
  def list(query_opts \\ []) do
    query_opts
    |> query_opts_to_fields()
    |> API.get("v1/channels.list")
    |> decode_success()
  end

  @doc """
  Get room info by id or name.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/info
  """
  def info(opts \\ []) do
    room_id_or_name(opts)
    |> API.get("v1/channels.info")
    |> decode_success()
  end

  @doc """
  Set the channel announcement on room by ID.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/setannouncement
  """
  def set_announcement(room_id, announcement) do
    %{"roomId" => room_id, "announcement" => announcement}
    |> API.post("v1/channels.setAnnouncement")
    |> decode_success()
  end

  @doc """
  Set the channel description on room by ID.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/setdescription
  """
  def set_description(room_id, description) do
    %{"roomId" => room_id, "description" => description}
    |> API.post("v1/channels.setDescription")
    |> decode_success()
  end

  @doc """
  Set the channel topic on room by ID.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/settopic
  """
  def set_topic(room_id, topic) do
    %{"roomId" => room_id, "topic" => topic}
    |> API.post("v1/channels.setTopic")
    |> decode_success()
  end

  @doc """
  Set channel to :private (type "p") or :public (type "c") on room by ID

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/settype

  NOTE:  The API permits either room ID or room name -- standardizing on ID
         here for simplicity.
  """
  def set_channel_type(room_id, type) when type in ["p", "c"] do
    %{"roomId" => room_id, "type" => type}
    |> API.post("v1/channels.setType")
    |> decode_success()
  end

  def set_channel_type(room_id, :private), do: set_channel_type(room_id, "p")
  def set_channel_type(room_id, :public), do: set_channel_type(room_id, "c")

  @doc """
  Set the channel readonly or not, on room by ID.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/setreadonly
  """
  def set_readonly(room_id, onoff) when is_boolean(onoff) do
    %{"roomId" => room_id, "readOnly" => onoff}
    |> API.post("v1/channels.setReadOnly")
    |> decode_success()
  end

  @doc """
  Add user (by ID) to room (by ID)

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/invite
  """
  def invite_user(room_id, user_id) do
    %{"roomId" => room_id, "userId" => user_id}
    |> API.post("v1/channels.invite")
    |> decode_success()
  end

  @doc """
  Kick user (by ID) from room (by ID)

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/kick
  """
  def kick_user(room_id, user_id) do
    %{"roomId" => room_id, "userId" => user_id}
    |> API.post("v1/channels.kick")
    |> decode_success()
  end

  defp room_id_or_name(opts) do
    case Keyword.get(opts, :name) do
      nil -> %{"roomId" => Keyword.fetch!(opts, :id)}
      name -> %{"roomName" => name}
    end
  end
end
