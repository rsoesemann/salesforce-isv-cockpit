// Note: Taken from https://salesforce.stackexchange.com/a/360012/256 with permission by author https://twitter.com/brianmfear/status/1572576591854841858
public class CsvParser {
    enum STATE { START_LINE, START_CELL, QUOTED, QUOTED_ESCAPED, UNQUOTED }
    public static List<Map<String, String>> parseCsv(String csv) {
        // Normalize newlines
        csv = csv.replace('\r\n','\n').replace('\n','\r').removeEnd('\r')+'\r';

        Boolean headerRow = true;
        Boolean newLine = true;
        Integer size = csv.length();
        Integer headerRowSize;
        STATE currentState = STATE.START_LINE;
        List<Map<String, String>> results = new List<Map<String, String>>();
        List<String> headers;
        List<String> values;
        Integer[] buffer;
        Map<String, String> result = new Map<String, String>();

        for(Integer index = 0; index < size; ) {
            Integer currentCharacter = csv.codePointAt(index);
            switch on currentState {
                when START_LINE {
                    values = new List<String>();
                    currentState = STATE.START_CELL;
                }
                when START_CELL {
                    switch on currentCharacter {
                        when 32 { // ' ': Skip leading spaces
                            index++;
                        }
                        when 34 { // '"': Quoted string
                            buffer = new Integer[0];
                            currentState = STATE.QUOTED;
                            index++;
                        }
                        when else { // Unquoted string
                            buffer = new Integer[0];
                            currentState = STATE.UNQUOTED;
                        }
                    }
                }
                when UNQUOTED {
                    switch on currentCharacter {
                        when 34 { // '"' not allowed in unquoted cell
                            throw new InvalidStateException('Invalid character in unquoted cell');
                        }
                        when 44 { // ',' end of cell
                            values.add(String.fromCharArray(buffer));
                            buffer.clear();
                            currentState = STATE.START_CELL;
                        }
                        when 13 { // '\r' end of line
                            values.add(String.fromCharArray(buffer));
                            buffer.clear();
                            currentState = STATE.START_LINE;
                            if(headerRow) {
                                headers = values;
                                headerRowSize = values.size();
                                headerRow = false;
                            } else {
                                Map<String, String> cellMap = new Map<String, String>();
                                if(values.size() > 0 && values.size() != headerRowSize) {
                                    throw new InvalidStateException('Cell count does not match header cell count');
                                }
                                for(Integer cellIndex = 0; cellIndex < headerRowSize; cellIndex++) {
                                    cellMap.put(headers[cellIndex], values[cellIndex]);
                                }
                                results.add(cellMap);
                            }
                        }
                        when else {
                            buffer.add(currentCharacter);
                        }
                    }
                    index++;
                }
                when QUOTED {
                    switch on currentCharacter {
                        when 34 { // '"' escape sequence
                            currentState = STATE.QUOTED_ESCAPED;
                        }
                        when else {
                            buffer.add(currentCharacter);
                        }
                    }
                    index++;
                }
                when QUOTED_ESCAPED {
                    switch on currentCharacter {
                        when 34 { // '"' adds a literal doublequote
                            buffer.add(currentCharacter);
                            currentState = STATE.QUOTED;
                            index++;
                        }
                        when 13, 44 { // end of cell or end of line, either way, we're done with quoted field.
                            // Loop back to use unquoted logic
                            currentState = STATE.UNQUOTED;
                        }
                        when else { // We don't permit other escaped quoted characters, per RFC 4180
                            throw new InvalidStateException('Escaped character must be followed by quote, comma, or newline');
                        }
                    }
                }
            }
        }

        return results;
    }
    public class InvalidStateException extends Exception { }
}