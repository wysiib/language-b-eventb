path = require 'path'
child_process = require 'child_process'

module.exports = class LinterProvider
  regex_parse_error_pre_151_beta7_format = "! An error occurred !\n! source\\(parse_error\\)\n! \\[(\\d+),(\\d+)\\] (.*) in file: (.*)"
  regex_parse_error = "! An error occurred !\n! source\\(parse_error\\)\n! (.*)\n\n?! Line: (\\d+) Column: (\\d+) in file: (.*)"
  regex_parse_error_no_position = "! An error occurred !\n! source\\(parse_error\\)\n! (.*) in file: (.*)"
  regex_type_error_pre_151_beta7_format = "! An error occurred !\n! source\\(type_error\\)\n! (.*)\n! (.*)\n! Line: (\\d+) Column: (\\d+) in file .*\n"
  regex_type_error = "! An error occurred !\n! source\\(type_error\\)\n! (.*)\n! Line: (\\d+) Column: (\\d+) in file: (.*)"

  getCommand = ->
    "#{atom.config.get 'language-b-eventb.probcliPath'} -p MAX_INITIALISATIONS 0 "

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
          console.log "B Linter Provider: #{line}"
          if line.match regex_parse_error_pre_151_beta7_format
            [line, column, message, file] = line.match(regex_parse_error_pre_151_beta7_format)[1..5]
            toReturn.push(
              type: "error",
              text: message,
              filePath: file.normalize()
              range: [[line - 1, column - 1], [line - 1, column - 1]]
            )
          if line.match regex_parse_error
            [message, line, column, file] = line.match(regex_parse_error)[1..5]
            toReturn.push(
              type: "error",
              text: message,
              filePath: file.normalize()
              range: [[line - 1, column - 1], [line - 1, column - 1]]
            )
          if line.match regex_parse_error_no_position
            [message, file] = line.match(regex_parse_error_no_position)[1..3]
            toReturn.push(
              type: "error",
              text: message,
              filePath: file.normalize()
            )
          if line.match regex_type_error_pre_151_beta7_format
            [message, file, line, column] = line.match(regex_type_error_pre_151_beta7_format)[1..5]
            toReturn.push(
              type: "error",
              text: message,
              filePath: file.normalize()
              range: [[line - 1, column - 1], [line - 1, column - 1]]
            )
          if line.match regex_type_error
            [message, line, column, file] = line.match(regex_type_error)[1..5]
            toReturn.push(
              type: "error",
              text: message,
              filePath: file.normalize()
              range: [[line - 1, column - 1], [line - 1, column - 1]]
            )
        Resolve toReturn
