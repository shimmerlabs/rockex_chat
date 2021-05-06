defmodule RocketChat.Channel do
  use RocketChat.Utils

  @doc """
  Create a channel with the given name.  Options:
  read_only: true/false  (default: false)
  members: array of usernames to add (default empty list)

  API Ref:  https://developer.rocket.chat/api/rest-api/methods/channels/create
  """
  @callback create(String.t()) :: tuple()
  @callback create(String.t(), keyword()) :: tuple()
  def create(name, opts \\ []) do
    %{
      "name" => name,
      "members" => Keyword.get(opts, :members, []),
      "readOnly" => Keyword.get(opts, :read_only, false)
    }
    |> adapter().post("v1/channels.create")
    |> decode_success()
  end

  @doc """
  Delete a channel by :id or :name -- one must defined.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/delete
  """
  @callback delete(keyword(id: String.t()) | keyword(name: String.t())) :: tuple()
  def delete(name_or_id) when is_list(name_or_id) do
    room_id_or_name(name_or_id)
    |> adapter().post("v1/channels.delete")
    |> decode_success()
  end

  @doc """
  List all channels

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/list
  """
  @callback list() :: tuple()
  @callback list(keyword()) :: tuple()
  def list(query_opts \\ []) do
    query_opts
    |> query_opts_to_fields()
    |> adapter().get("v1/channels.list")
    |> decode_success()
  end

  @doc """
  Get room info by id or name.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/info
  """
  @callback info(keyword(id: String.t()) | keyword(name: String.t())) :: tuple()
  def info(opts \\ []) do
    room_id_or_name(opts)
    |> adapter().get("v1/channels.info")
    |> decode_success()
  end

  @doc """
  Set the channel announcement on room by ID.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/setannouncement
  """
  @callback set_announcement(String.t(), String.t()) :: tuple()
  def set_announcement(room_id, announcement) do
    %{"roomId" => room_id, "announcement" => announcement}
    |> adapter().post("v1/channels.setAnnouncement")
    |> decode_success()
  end

  @doc """
  Set the channel description on room by ID.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/setdescription
  """
  @callback set_description(String.t(), String.t()) :: tuple()
  def set_description(room_id, description) do
    %{"roomId" => room_id, "description" => description}
    |> adapter().post("v1/channels.setDescription")
    |> decode_success()
  end

  @doc """
  Set the channel topic on room by ID.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/settopic
  """
  @callback set_topic(String.t(), String.t()) :: tuple()
  def set_topic(room_id, topic) do
    %{"roomId" => room_id, "topic" => topic}
    |> adapter().post("v1/channels.setTopic")
    |> decode_success()
  end

  @doc """
  Set channel to :private (type "p") or :public (type "c") on room by ID

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/settype

  NOTE:  The API permits either room ID or room name -- standardizing on ID
         here for simplicity.
  """
  @callback set_channel_type(String.t(), String.t() | :private | :public) :: tuple()
  def set_channel_type(room_id, type) when type in ["p", "c"] do
    %{"roomId" => room_id, "type" => type}
    |> adapter().post("v1/channels.setType")
    |> decode_success()
  end

  def set_channel_type(room_id, :private), do: set_channel_type(room_id, "p")
  def set_channel_type(room_id, :public), do: set_channel_type(room_id, "c")

  @doc """
  Set the channel readonly or not, on room by ID.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/setreadonly
  """
  @callback set_readonly(String.t(), boolean()) :: tuple()
  def set_readonly(room_id, onoff) when is_boolean(onoff) do
    %{"roomId" => room_id, "readOnly" => onoff}
    |> adapter().post("v1/channels.setReadOnly")
    |> decode_success()
  end

  @doc """
  Add user (by ID) to room (by ID)

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/invite
  """
  @callback invite_user(String.t(), String.t()) :: tuple()
  def invite_user(room_id, user_id) do
    %{"roomId" => room_id, "userId" => user_id}
    |> adapter().post("v1/channels.invite")
    |> decode_success()
  end

  @doc """
  Kick user (by ID) from room (by ID)

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/kick
  """
  @callback kick_user(String.t(), String.t()) :: tuple()
  def kick_user(room_id, user_id) do
    %{"roomId" => room_id, "userId" => user_id}
    |> adapter().post("v1/channels.kick")
    |> decode_success()
  end

  @doc """
  Cause the callee (account configured) to leave the given channel by ID.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/leave
  """
  @callback leave(String.t()) :: tuple()
  def leave(room_id) do
    %{"roomId" => room_id}
    |> adapter().post("v1/channels.leave")
    |> decode_success()
  end

  @doc """
  Set user (by ID) as moderator of room (by ID)

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/addmoderator
  """
  @callback set_moderator(String.t(), String.t()) :: tuple()
  def set_moderator(room_id, user_id) do
    %{"roomId" => room_id, "userId" => user_id}
    |> adapter().post("v1/channels.addModerator")
    |> decode_success()
  end

  @doc """
  Set user (by ID) as owner of room (by ID)

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/addowner
  """
  @callback set_owner(String.t(), String.t()) :: tuple()
  def set_owner(room_id, user_id) do
    %{"roomId" => room_id, "userId" => user_id}
    |> adapter().post("v1/channels.addOwner")
    |> decode_success()
  end

  @doc """
  List members of channel (by name or id)

  API Ref: https://developer.rocket.chat/api/rest-api/methods/channels/list
  """
  @callback members(keyword(id: String.t()) | keyword(name: String.t())) :: tuple()
  def members(id_or_name) when is_list(id_or_name) do
    id_or_name
    |> room_id_or_name()
    |> adapter().get("v1/channels.members")
    |> decode_success()
  end

  defp room_id_or_name(opts) do
    case Keyword.get(opts, :name) do
      nil -> %{"roomId" => Keyword.fetch!(opts, :id)}
      name -> %{"roomName" => name}
    end
  end
end
