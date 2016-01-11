defmodule TriangleTest do
  use ExUnit.Case

  test "area" do
    assert Triangle.area(3, 5) == 7.5
  end

  test "default equilateral size" do
    assert Triangle.equilateral == {5, 5, 5}
  end
end
