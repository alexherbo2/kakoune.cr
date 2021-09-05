require "./session"
require "./client"

class Kakoune::Context
  property session_name
  property client_name

  def initialize(session @session_name : String?, client @client_name : String?)
  end

  def scope
    if client?
      client
    elsif session?
      session
    else
      nil
    end
  end

  def scoped?
    scope != nil
  end

  def session
    Session.new(session_name.to_s)
  end

  def client
    session.client(client_name.to_s)
  end

  def session?
    session_name.is_a?(String) && session_name.presence
  end

  def client?
    session? && client_name.is_a?(String) && client_name.presence
  end
end
