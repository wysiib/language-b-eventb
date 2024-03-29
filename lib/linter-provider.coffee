path = require 'path'
child_process = require 'child_process'

module.exports = class LinterProvider
  regex_error = "! An error occurred !\r?\n! source\\(([a-zA-Z]|\\d+|_)*\\)\r?\n! (.*)\r?\n! [lL]ine: (\\d+) [cC]olumn: (-?\\d+) until (\\d+):(\\d+) in [fF]ile: (.*)"
  regex_error_old = "! An error occurred !\r?\n! source\\(([a-zA-Z]|\\d+|_)*\\)\r?\n! (.*)\r?\n! [lL]ine: (\\d+) [cC]olumn: (\\d+) in [fF]ile: (.*)"
  regex_error_181 = "! An error occurred \\(source: ([a-zA-Z]|\\d+|_)*\\).*\r?\n! (.*)\r?\n.*\r?\n?! [lL]ine: (\\d+) [cC]olumn: (-?\\d+) until [lL]ine: (\\d+) [cC]olumn: (\\d+) in [fF]ile: (\\S*)"
  regex_warning_181 = "! A warning occurred \\(source: ([a-zA-Z]|\\d+|_)*\\).*\r?\n! (.*)\r?\n.*\r?\n?! [lL]ine: (\\d+) [cC]olumn: (-?\\d+) until [lL]ine: (\\d+) [cC]olumn: (\\d+) in [fF]ile: (\\S*)"
  regex_definition = "within DEFINITION call of (([a-zA-Z]|\\d+|_)*) at [lL]ine: (\\d+) [cC]olumn: (-?\\d+) until [lL]ine: (\\d+) [cC]olumn: (\\d+) in [fF]ile: (\\S*)"
  regex_message_181 = ".*! Message \\(source: ([a-zA-Z]|\\d+|_)*\\).*\r?\n! (.*)\r?\n.*\r?\n?! [lL]ine: (\\d+) [cC]olumn: (-?\\d+) until [lL]ine: (\\d+) [cC]olumn: (\\d+) in [fF]ile: (\\S*).*"
  regex_parse_error_no_position = "! An error occurred !\r?\n! source\\(([a-zA-Z]|\\d+|_)*\\)\r?\n! (.*) in [fF]ile: (.*)"

  getCommand = ->
    if (atom.config.get('language-b-eventb.probCheckWD'))
      wdcmd = " -wd-check -release_java_parser"
    else
      wdcmd = ""
    if (atom.config.get('language-b-eventb.probStricterStaticChecks'))
      opts = " -p STRICT_CLASH_CHECKING TRUE -p TYPE_CHECK_DEFINITIONS TRUE -lint"
    else
      opts = ""
    "#{atom.config.get 'language-b-eventb.probcliPath'} -p MAX_INITIALISATIONS 0 -version" + opts + wdcmd

  getCommandWithFile = (file, nullFile) -> "#{getCommand()} #{file}"

  lint: (TextEditor) ->
    new Promise (Resolve) ->
      loadedFile = path.basename TextEditor.getPath()
      file = path.basename TextEditor.getPath()
      cwd = path.dirname TextEditor.getPath()
      data_stderr = []
      data_stdout = []
      console.log "*** Platform: #{navigator.platform} ***"
      isWin = /^WIN/.test(navigator.platform.toUpperCase())
      nullFile = if isWin then "nul" else "/dev/null"
      command = getCommandWithFile(file, nullFile)
      console.log "Linter Command: #{command}"
      process = child_process.exec command, {cwd: cwd}
      process.stderr.on 'data', (d) -> data_stderr.push d.toString()
      process.stdout.on 'data', (d) -> data_stdout.push d.toString()
      process.on 'close', ->
        toReturn = []

        all_stderr = data_stderr.join('') #combining all elements of data to one string (this is required because one element does not correspond to one error)
        all_stderr = all_stderr.replace(/(\u001B\[\d\d?m)/g, "") #remove escape sequences used for color codes
        console.log "*** B Linter Provider all messages on stderr ***\n#{all_stderr}\n*** end of messages ***"

        all_stdout = data_stdout.join('') #combining all elements of data to one string (this is required because one element does not correspond to one error)
        all_stdout = all_stdout.replace(/(\u001B\[\d\d?m)/g, "") #remove escape sequences used for color codes
        console.log "*** B Linter Provider all messages on stdout ***\n#{all_stdout}\n*** end of messages ***"

        regex_all_matches = new RegExp(regex_error_181, "g") #all matches
        res_array = all_stderr.match regex_all_matches
        console.log "res_array 181 errors: #{res_array}"
        if res_array
          for res in res_array
            result = res.match regex_error_181
            [errorType, message, line1, column1, line2, column2, file] = result[1..7]
            toReturn.push(
              severity: "error",
              excerpt: message,
              location: {
                file: file.normalize(),
                position: [[line1 - 1, parseInt(column1)], [line2 - 1, parseInt(column2)]]
              }
              linterName: "ProB on " + loadedFile.normalize()
            )
        
        regex_all_matches = new RegExp(regex_warning_181, "g") #all matches
        res_array = all_stderr.match regex_all_matches
        console.log "res_array 181 warnings: #{res_array}"
        if res_array
          for res in res_array
            result = res.match regex_warning_181
            [errorType, message, line1, column1, line2, column2, file] = result[1..7]
            toReturn.push(
              severity: "warning",
              excerpt: message,
              location: {
                file: file.normalize(),
                position: [[line1 - 1, parseInt(column1)], [line2 - 1, parseInt(column2)]]
              }
              linterName: "ProB on " + loadedFile.normalize()
            )
        
        regex_all_matches = new RegExp(regex_definition, "g") #all matches
        res_array = all_stderr.match regex_all_matches
        console.log "res_array regex_definition: #{res_array}"
        if res_array
          for res in res_array
            result = res.match regex_definition
            [defname, lastchar, line1, column1, line2, column2, file] = result[1..7]
            console.log "def = " + defname
            toReturn.push(
              severity: "info",
              excerpt: "Subsidiary error/warnings caused within " + defname,
              location: {
                file: file.normalize(),
                position: [[line1 - 1, parseInt(column1)], [line2 - 1, parseInt(column2)]]
              }
              linterName: "ProB on " + loadedFile.normalize()
            )
            
        regex_all_matches = new RegExp(regex_message_181, "g") #all matches
        res_array = all_stdout.match regex_all_matches
        console.log "res_array 181 messages: #{res_array}"
        if res_array
          for res in res_array
            result = res.match regex_message_181
            [errorType, message, line1, column1, line2, column2, file] = result[1..7]
            toReturn.push(
              severity: "info",
              excerpt: message,
              location: {
                file: file.normalize(),
                position: [[line1 - 1, parseInt(column1)], [line2 - 1, parseInt(column2)]]
              }
              linterName: "ProB on " + loadedFile.normalize()
            )

        regex_all_matches = new RegExp(regex_error, "g") #all matches
        res_array = all_stderr.match regex_all_matches
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
        res_array = all_stderr.match regex_all_matches
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
        res_array = all_stderr.match regex_all_matches
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
