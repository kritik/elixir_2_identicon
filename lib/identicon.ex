defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
  Main function to generate picture.

  ## Examples

      iex> Identicon.main("Vladimir Krylov")
      :world

  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end
  
  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
  
  def draw_image(%Identicon.Image{color: color,pixel_map: map}=_image) do
    image = :egd.create(5*50,5*50)
    fill = :egd.color(color)
    Enum.each(map, fn ({start,stop})->
      :egd.filledRectangle(image, start, stop, fill)
    end)
    :egd.render(image)
  end
  
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    map = Enum.map grid, fn({_code,idx}) ->
      x = rem(idx, 5)*50
      y = div(idx,5)*50
      p1 = {x, y}
      p2 = {x+50,y+50}
      {p1,p2} 
    end
    %Identicon.Image{image| pixel_map: map}
  end
  
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn {x,_} ->
      rem(x, 2) == 0 
    end
    %Identicon.Image{image| grid: grid}
  end
  
  def build_grid(%{hex: hex} = image) do
    grid = 
      hex
      |> Enum.chunk_every(3,3, :discard)
      |> Enum.map(&mirror_row/1) # sending reference
      |> List.flatten
      |> Enum.with_index
    %Identicon.Image{image| grid: grid}
  end
  
  
  @doc """
  Inputs `row` is a List with 3 elements [a,b,c].
  It outputs [a,b,c,b,a]
  
  ## Examples
        iex> Identicon.mirror_row([1,2,3])
        [1,2,3,2,1]
  """
  def mirror_row(row) do
    [first,second|_] = row
    row ++ [second, first] # joins lists
  end
  
  def pick_color(%Identicon.Image{hex: [r,g,b|_]}=image) do
    # or %{hex: [r,g,b|_]} = image
    # %Identicon.Image{image| color: {r,g,b}}

    %{image| color: {r,g,b}}
  end
  
  @doc """
  Returns md5 signature of the input string
  
  ## Examples
      iex> Identicon.hash_input("qwerty")
      %Identicon.Image{hex: [216, 87, 142, 223, 132, 88, 206, 6, 251, 197, 187, 118, 165, 140, 92, 164]}
  """
  def hash_input(input) do
    # hash = :erlang.md5(input) # also works
    hex = :crypto.hash(:md5, input)
    |>:binary.bin_to_list
    
    %Identicon.Image{hex: hex}
  end
end
