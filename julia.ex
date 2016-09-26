    defmodule Complex_funcs do

      def cplx_add(number1, number2) do
        new(number1[:real] + number2[:real], number1[:img] + number2[:img])
      end

      def cplx_sub(number1, number2) do
        new(number1[:real] - number2[:real], number1[:img] - number2[:img])
      end  

      def cplx_mul(number1, number2) do
        real = number1[:real] * number2[:real] - number1[:img] * number2[:img]
        img = number1[:real] * number2[:img] + number1[:img] * number2[:real]
        new(real, img)
      end  

      def new(real, img) do
        %{:real => real, :img => img}
      end
      
      def puts(complex) do
        if complex[:img] > 0 do
          IO.puts("#{complex[:real]}+#{complex[:img]}j")
        else
          IO.puts("#{complex[:real]}#{complex[:img]}j")
        end
      end

      def format(complex) do
        if complex[:img] > 0 do
          "#{complex[:real]}+#{complex[:img]}j"
        else
          "#{complex[:real]}#{complex[:img]}j"
        end
      end

      def loop_y(row, x, i, y, h) when y < length(h) do
        z = new(i, Enum.at(h, y))
        g = abs_loop(z, 0, distance(z))
        row_ = List.update_at(row, y, fn(_) -> g end)
        loop_y(row_, x, i, y+1, h)
      end

      def loop_y(c, x, _, _, _) do
        {x, c}
      end

      def loop_x(x, c, w, h) when x < length(c) do
        i = Enum.at(w, x)
        master = self()
        spawn(fn ->
          row = loop_y(Enum.at(c, x), x, i, 0, h)
          send master, row
        end)
        loop_x(x+1, c, w, h)
      end

      def loop_x(_, _, _, _) do
        IO.puts("Finished")
      end

      def distance(z) do
        :math.sqrt(abs(z[:real]) + abs(z[:img]))
      end

      def abs_loop(z, g, d) when g < 255 and d < 2 do
        z_ = f(z)
        abs_loop(z_, g + 1, distance(z_))
      end

      def abs_loop(_, g, _) do
        g
      end

      def f(z) do
        cplx_add(
            cplx_mul(z, z),
            new(-0.7269, 0.1889)
          )
      end

      def filled_list(w, h) do
        l = []
        t = Enum.to_list(Stream.iterate(0, &(&1)) |> Enum.take(h))
        l = for _ <- 0..w - 1 do
          l ++ t
        end
        l
      end

      def generate(width, height) do
        w = Stream.iterate(-1, &(&1+1/width)) |> Enum.take(width*2)
        h = Stream.iterate(-1, &(&1+1/width)) |> Enum.take(height*2)
        c = filled_list(width, height)
        loop_x(0, c, w, h)
      end

      def collect(w) do
        File.open "dataset.txt", [:write, :raw], fn file ->
          :file.write(file, "{")
          for _ <- 0..w-1 do
            receive do
              {x, row} -> {x, row}
              :file.write(file, "#{x}:[")
              for v <- row do
                :file.write(file, "#{v},")
              end 
              :file.write(file, "],")
            end
          end
          :file.write(file, "}")
          File.close file
          IO.puts("Starting pillow to display image.")
          System.cmd("python3", ["loader.py"])
        end
      end
    end

width = 500
height = 1000
Complex_funcs.generate(width, height)
Complex_funcs.collect(width)
