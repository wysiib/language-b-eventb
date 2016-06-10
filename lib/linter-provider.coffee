path = require 'path'
child_process = require 'child_process'

module.exports = class LinterProvider
  regex_parse_error_pre_151_beta7_format = "! An error occurred !\n! source\\(parse_error\\)\n! \\[(\\d+),(\\d+)\\] (.*) in file: (.*)"
  regex_type_error_pre_151_beta7_format = "! An error occurred !\n! source\\(type_error\\)\n! (.*)\n! (.*)\n! Line: (\\d+) Column: (\\d+) in file .*\n"
  regex_error = "! An error occurred !\n! source\\(([a-zA-Z]|\\d+|_)*\\)\n! (.*)\n! Line: (\\d+) Column: (\\d+) until (\\d+):(\\d+) in file: (.*)"
  regex_error_old = "! An error occurred !\n! source\\(([a-zA-Z]|\\d+|_)*\\)\n! (.*)\n! Line: (\\d+) Column: (\\d+) in file: (.*)"
  regex_parse_error_no_position = "! An error occurred !\n! source\\(([a-zA-Z]|\\d+|_)*\\)\n! (.*) in file: (.*)"

  getCommand = ->
    "#{atom.config.get 'language-b-eventb.probcliPath'} -p MAX_INITIALISATIONS 0 -p show_full_error_span true "

  getCommandWithFile = (file) -> "#{getCommand()} #{file} 1>/dev/null"

  lint: (TextEditor) ->
    new Promise (Resolve) ->
      file = path.basename TextEditor.getPath()
      cwd = path.dirname TextEditor.getPath()
      data = []
      command = getCommandWithFile file
      console.log "Linter Command: #{command}"
      process = child_process.exec command, {cwd: cwd}
      process.stderr.on 'data', (d) -> data.push d.toString()
      process.on 'close', ->
        toReturn = []
        for line in data
          console.log "B Linter Provider line: #{line}"
          regex_all = new RegExp(regex_parse_error_pre_151_beta7_format, "g"); #all matches
          res_array = line.match regex_all
          if res_array
            for res in res_array
              result = res.match regex_parse_error_pre_151_beta7_format
              [line, column, message, file] = result[1..4]
              toReturn.push(
                type: "error",
                text: message,
                filePath: file.normalize()
                range: [[line - 1, parseInt(column)], [line - 1, parseInt(column)]]
              )

          regex_all = new RegExp(regex_type_error_pre_151_beta7_format, "g"); #all matches
          res_array = line.match regex_all
          if res_array
            for res in res_array
              result = res.match regex_type_error_pre_151_beta7_format
              [message, file, line, column] = result[1..4]
              toReturn.push(
                type: "error",
                text: message,
                filePath: file.normalize()
                range: [[line - 1, parseInt(column)], [line - 1, parseInt(column)]]
              )

          regex_all = new RegExp(regex_error, "g"); #all matches
          res_array = line.match regex_all
          if res_array
            for res in res_array
              result = res.match regex_error
              [errorType, message, line1, column1, line2, column2, file] = result[1..7]
              toReturn.push(
                type: "error",
                text: message,
                filePath: file.normalize()
                range: [[line1 - 1, parseInt(column1)], [line2 - 1, parseInt(column2)]]
              )

          regex_all = new RegExp(regex_error_old, "g"); #all matches
          res_array = line.match regex_all
          if res_array
            for res in res_array
              result = res.match regex_error_old
              [errorType, message, line1, column1, file] = result[1..5]
              toReturn.push(
                type: "error",
                text: message,
                filePath: file.normalize()
                range: [[line1 - 1, parseInt(column1)], [line1 - 1, parseInt(column1)]]
              )

          regex_all = new RegExp(regex_parse_error_no_position, "g"); #all matches
          res_array = line.match regex_all
          if res_array
            for res in res_array
              result = res.match regex_parse_error_no_position
              [errorType,message, file] = result[1..3]
              toReturn.push(
                type: "error",
                text: message,
                filePath: file.normalize()
              )
        Resolve toReturn
