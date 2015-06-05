require 'matrix'

class RosterMatrix < Matrix

  # rows are positions
  # cols are Rosters
  def self.balance_roster_array matrix
    return nil if matrix.nil?
    return nil unless matrix.is_a?(RosterMatrix)
    @max_salary = 33000

    count = 0
    last_swap = []
    max_swaps = matrix.row_size * matrix.column_size * 3

    while !is_balanced?(matrix)
      if count > max_swaps
        matrix = nil
        break
      end

      p = get_swap matrix, last_swap
      matrix = swap_point(matrix, p)
      puts "Count :: #{count} :: Swapped :: #{p.inspect}"
      count = count + 1
      last_swap = p
    end

    matrix
  end

  def self.to_roster_array
    [].to_a
  end

  private
  
    def self.is_balanced? matrix
      (0..matrix.column_size-1).each do |col_index|
        return false if matrix.column(col_index).sum { |g| g.salary } > @max_salary
      end

      true
    end

    def self.swap_point init_matrix, swap_array
      RosterMatrix.build(init_matrix.row_size, init_matrix.column_size) do |row, col|
        if swap_array.index([row, col])
          case swap_array.index([row, col])
          when 0
            init_matrix [swap_array[1][0], swap_array[1][1]]
          when 1
            init_matrix [swap_array[0][0], swap_array[0][1]]
          end
        else
          init_matrix[row, col]
        end
      end
    end

    def self.get_swap init_matrix, exclude_point
      outer_swap = nil
      outer_value = 9999999999

      init_matrix.each_with_index do |e, row, col|
        # don't process this column (roster) if already under the cap.
        next if init_matrix.column(col).sum { |h| h.salary } < @max_salary

        m = create_salary_matrix(init_matrix, row, col, exclude_point)

        min_value = 9999999999
        min_swap = [[-1, -1], [-1, -1]]

        (0..m.column_size-1).each do |col_index|
          next if col_index == col
          next if m.column(col_index).count { |g| g <= 0 } > 0

          value = m.column(col_index).sum { |g| g }
          if value < min_value
            min_value = value
            min_swap = [[row, col], [row, col_index]]
          end
        end

        if min_value < outer_value
          outer_value = min_value
          outer_swap = min_swap
        end

      end

      outer_swap
    end

    # rows are positions
    # cols are Rosters
    def self.create_salary_matrix init_matrix, c_row, c_col, exclude_point
      player = init_matrix[c_row, c_col]
      roster_salary_for_player = init_matrix(c_col).sum { |h| h.salary }
      exclude_point = [] if exclude_point.nil?

      pt = RosterMatrix.build(init_matrix.row_size, init_matrix.column_size) do |row, col|
        # puts "exclude points :: #{exclude_point.inspect} - row: #{row} - col: #{col} - skip? :: #{exclude_point.include?([row,col])}"
        if exclude_point.include?([row,col])
          0
        elsif col == c_col
          # same cols - or roster - that processing = set all of it to 0
          0
        elsif row == c_row

          # going to have to calculate the difference to the roster.
          # if the column roster

          # if both put the rosters under set this column to 100 (so it gets picked
          # or another column that puts both under gets picked)
          swap_player = init_matrix[row, col]

          # salaries are the same - don't swap at all
          if player.salary == swap_player.salary
            0
          else
            # if current rotser is over the cap and making the swap will put 
            # both rosters under the salary cap - make this swap a priority
            if roster_salary_for_player > @max_salary &&
               init_matrix.column(col).sum { |h| h.salary } - swap_player.salary + player.salary < @max_salary &&
               init_matrix.column(c_col).sum { |h| h.salary } - player.salary + swap_player.salary < @max_salary
              100

            # check to see if the players swapping will be swapping with a column that the player
            # is already in. if so don't swap that one to make an illegal roster
            elsif init_matrix.column(col).detect { |p| p.id == player.id }
              0

            # otherwise just subtract the salary to see how good of a swap it is
            else
              player.salary - init_matrix[row, col].salary
            end
          end
        else
          # not in the col or row - so this would just be ignored and put the salary
          # of players not being swapped in the matrix
          init_matrix[row, col].salary
        end
      end

      pt
    end

end
