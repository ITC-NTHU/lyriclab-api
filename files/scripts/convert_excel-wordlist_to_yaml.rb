require 'roo'

xlsx = Roo::Spreadsheet.open("files/mandarin_word_list.xlsx")
      word_list = {
        novice1: [],
        novice2: [],
        level1: [],
        level2: [],
        level3: [],
        level4: [],
        level5: []
      }
      list_names = [:novice1, :novice2, :level1, :level2, :level3, :level4, :level5]
      puts "empty: #{word_list[list_names[0]]}"
      puts "test"
      puts "availabe sheets: #{xlsx.sheets}"
      if xlsx.sheets.include?("Sheet1")
        xlsx.sheets.delete("Sheet1")
      end
      puts "availabe sheets: #{xlsx.sheets}"

      xlsx.sheets.each_with_index do |sheet_name, index|
        sheet = xlsx.sheet(sheet_name)
        puts "index: #{index}"
        puts "list_names[index]: #{list_names[index]}"
        sheet.each_row_streaming do |row|
          characters = row[0].to_s
          pinyin = row[1].to_s
          word_type = row[2].to_s
          if !characters.nil? and !pinyin.nil? and !characters.include?('/') and !pinyin.include?('/')
            word_list[list_names[index]].push([characters, pinyin, word_type])
          end
        end
      end

      require 'yaml'

      File.open("files/mandarin_word_list.yml", "w") do |file|
        file.write(word_list.to_yaml)
      end
