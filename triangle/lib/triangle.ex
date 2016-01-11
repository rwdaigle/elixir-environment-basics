defmodule Triangle do

  def area(base, height) do
    Metrix.measure "triangle.area.service", fn ->
      base * height / 2
    end
  end

  def equilateral, do: equilateral(Application.get_env(:triangle, :default_length))
  def equilateral(length), do: {length, length, length}

end
