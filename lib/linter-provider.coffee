path = require 'path'
child_process = require 'child_process'

module.exports = class LinterProvider
  regex_parse_error_pre_151_beta7_format = "! An error occurred !\r?\n! source\\(parse_error\\)\r?\n! \\[(\\d+),(\\d+)\\] (.*) in file: (.*)"
  regex_type_error_pre_151_beta7_format = "! An error occurred !\r?\n! source\\(type_error\\)\r?\n! (.*)\r?\n! (.*)\r?\n! Line: (\\d+) Column: (\\d+) in file .*\r?\n"
  regex_error = "! An error occurred !\r?\n! source\\(([a-zA-Z]|\\d+|_)*\\)\r?\n! (.*)\r?\n! Line: (\\d+) Column: (-?\\d+) until (\\d+):(\\d+) in file: (.*)"
  regex_error_old = "! An error occurred !\r?\n! source\\(([a-zA-Z]|\\d+|_)*\\)\r?\n! (.*)\r?\n! Line: (\\d+) Column: (\\d+) in file: (.*)"
  regex_parse_error_no_position = "! An error occurred !\r?\n! source\\(([a-zA-Z]|\\d+|_)*\\)\r?\n! (.*) in file: (.*)"

  getCommand = ->
    "#{atom.config.get 'language-b-eventb.probcliPath'} -p MAX_INITIALISATIONS 0 -p show_full_error_span true "

  getCommandWithFile = (file, nullFile) -> "#{getCommand()} #{file} 1>#{nullFile}"

  lint: (TextEditor) ->
    new Promise (Resolve) ->
      file = path.basename TextEditor.getPath()
      cwd = path.dirname TextEditor.getPath()
      data = []
      console.log "*** Platform: #{navigator.platform} ***"
      isWin = /^WIN/.test(navigator.platform.toUpperCase())
      nullFile = if isWin then "nul" else "/dev/null"
      command = getCommandWithFile(file, nullFile)
      console.log "Linter Command: #{command}"
      process = child_process.exec command, {cwd: cwd}
      process.stderr.on 'data', (d) -> data.push d.toString()
      process.on 'close', ->
        toReturn = []
        all = data.join('') #combining all elements of data to one string (this is required because one element does not correspond to one error)
        console.log "*** B Linter Provider all messages ***\n#{all}\n*** end of messages ***"

        regex_all_matches = new RegExp(regex_parse_error_pre_151_beta7_format, "g") #all matches
        res_array = all.match regex_all_matches
        if res_array
          for res in res_array
            result = res.match regex_parse_error_pre_151_beta7_format
            [line, column, message, file] = result[1..4]
            toReturn.push(
              severity: "error",
              excerpt: message,
              location: {
                file: file.normalize(),
                position: [[line - 1, parseInt(column)], [line - 1, parseInt(column)]]
              }
            )

        regex_all_matches = new RegExp(regex_type_error_pre_151_beta7_format, "g") #all matches
        res_array = all.match regex_all_matches
        if res_array
          for res in res_array
            result = res.match regex_type_error_pre_151_beta7_format
            [message, file, line, column] = result[1..4]
            toReturn.push(
              severity: "error",
              excerpt: message,
              location: {
                file: file.normalize(),
                position: [[line - 1, parseInt(column)], [line - 1, parseInt(column)]]
              }
            )

        regex_all_matches = new RegExp(regex_error, "g") #all matches
        res_array = all.match regex_all_matches
        if res_array
          for res in res_array
            result = res.match regex_error
            [errorType, message, line1, column1, line2, column2, file] = result[1..7]
            toReturn.push(
              severity: "error",
              excerpt: message,
              location: {
                file: file.normalize(),
                position: [[line1 - 1, parseInt(column1)], [line2 - 1, parseInt(column2)]]
              }
            )

        regex_all_matches = new RegExp(regex_error_old, "g") #all matches
        res_array = all.match regex_all_matches
        if res_array
          for res in res_array
            result = res.match regex_error_old
            [errorType, message, line, column, file] = result[1..5]
            toReturn.push(
              severity: "error",
              excerpt: message,
              location: {
                file: file.normalize(),
                position: [[line - 1, parseInt(column)], [line - 1, parseInt(column)]]
              }
            )

        regex_all_matches = new RegExp(regex_parse_error_no_position, "g") #all matches
        res_array = all.match regex_all_matches
        if res_array
          for res in res_array
            result = res.match regex_parse_error_no_position
            [errorType, message, file] = result[1..3]
            toReturn.push(
              severity: "error",
              excerpt: message,
              location: {
                file: file.normalize()
              }
            )
        Resolve toReturn
