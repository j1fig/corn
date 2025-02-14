defmodule Corn.Cfg do
  @default_delay 0

  def get do
    Application.get_all_env(:corn)
  end

  def unpack(opts) do
    mod =     Keyword.get(opts, :module)
    fun =     Keyword.get(opts, :function)
    period =  Keyword.get(opts, :period)
    delay =   Keyword.get(opts, :delay, @default_delay)
    {mod, fun, period, delay}
  end
end
