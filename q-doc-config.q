// q-doc Code Documentation Generator
//   Configuration
// Copyright (C) 2014 Jaskirat M.S. Rajasansir
// License BSD, see LICENSE for details


/ Defines the mapping between the supported types for q-doc and the underlying q types. All list
/ types are also defined by appending 'List' to each type. Further, some custom types have also
/ been defined with non-standard kdb type values.
/ NOTE: You should ignore the custom type values unless interested in writing your own q-doc generator.
/ NOTE 2: The types are currently case-sensitive.
.qdoc.parser.types.input:(!)."SH"$\:();
.qdoc.parser.types.input[`Bool`Boolean]:-1h;
.qdoc.parser.types.input[`GUID]:-2h;
.qdoc.parser.types.input[`Byte]:-4h;
.qdoc.parser.types.input[`Short`ShortInt`Int16]:-5h;
.qdoc.parser.types.input[`Integer`Int`Int32]:-6h;
.qdoc.parser.types.input[`Long`LongInt`Int64]:-7h;
.qdoc.parser.types.input[`Real`Single]:-8h;
.qdoc.parser.types.input[`Float`Double]:-9h;
.qdoc.parser.types.input[`Char`Character]:-10h;
.qdoc.parser.types.input[`Symbol`Sym]:-11h;
.qdoc.parser.types.input[`Timestamp]:-12h;
.qdoc.parser.types.input[`Month]:-13h;
.qdoc.parser.types.input[`Date]:-14h;
.qdoc.parser.types.input[`Datetime]:-15h;
.qdoc.parser.types.input[`Timespan]:-16h;
.qdoc.parser.types.input[`Minute`Min]:-17h;
.qdoc.parser.types.input[`Second`Sec]:-18h;
.qdoc.parser.types.input[`Time]:-19h;

.qdoc.parser.types.input[`True]:-30h;
.qdoc.parser.types.input[`False]:-31h;
.qdoc.parser.types.input[`Number]:-35h;
.qdoc.parser.types.input[`File]:-40h;
.qdoc.parser.types.input[`Folder]:-41h;
.qdoc.parser.types.input[`FilePath]:-42h;
.qdoc.parser.types.input[`FolderPath]:-43h;
.qdoc.parser.types.input[`Host]:-44h;
.qdoc.parser.types.input[`Port]:-45h;
.qdoc.parser.types.input[`Path]:-46h;
.qdoc.parser.types.input[`String]:-50h;

.qdoc.parser.types.input,:(!).({ `$string[x],"List" };abs)@/:'(key .qdoc.parser.types.input;value .qdoc.parser.types.input);

.qdoc.parser.types.input[`]:0Nh;
.qdoc.parser.types.input[`Atom]:-0Wh;
.qdoc.parser.types.input[`List]:0h;
.qdoc.parser.types.input[`Table]:98h;
.qdoc.parser.types.input[`Dict]:99h;
.qdoc.parser.types.input[`Function]:100h;


.qdoc.parser.types.output:(!)."HS"$\:();
.qdoc.parser.types.output[-1h]:`Boolean;
.qdoc.parser.types.output[-2h]:`GUID;
.qdoc.parser.types.output[-4h]:`Byte;
.qdoc.parser.types.output[-5h]:`$"16-bit Integer";
.qdoc.parser.types.output[-6h]:`$"32-bit Integer";
.qdoc.parser.types.output[-7h]:`$"64-bit Integer";
.qdoc.parser.types.output[-8h]:`$"Single precision floating point";
.qdoc.parser.types.output[-9h]:`$"Double precision floating point";
.qdoc.parser.types.output[-10h]:`Character;
.qdoc.parser.types.output[-11h]:`Symbol;
.qdoc.parser.types.output[-12h]:`Timestamp;
.qdoc.parser.types.output[-13h]:`Month;
.qdoc.parser.types.output[-14h]:`Date;
.qdoc.parser.types.output[-15h]:`$"Datetime (deprecated)";
.qdoc.parser.types.output[-16h]:`Timespan;
.qdoc.parser.types.output[-17h]:`Minute;
.qdoc.parser.types.output[-18h]:`Second;
.qdoc.parser.types.output[-19h]:`Time;

.qdoc.parser.types.output[-30h]:`$"Boolean True";
.qdoc.parser.types.output[-31h]:`$"Boolean False";
.qdoc.parser.types.output[-35h]:`$"Any number type";
.qdoc.parser.types.output[-40h]:`$"File name";
.qdoc.parser.types.output[-41h]:`$"Folder name";
.qdoc.parser.types.output[-42h]:`$"File path";
.qdoc.parser.types.output[-43h]:`$"Folder path";
.qdoc.parser.types.output[-44h]:`$"Hostname";
.qdoc.parser.types.output[-45h]:`$"Port number";
.qdoc.parser.types.output[-46h]:`$"File or folder path";
.qdoc.parser.types.output[-50h]:`String;

.qdoc.parser.types.output,:(!).(abs;{ `$string[x]," list" })@/:'(key .qdoc.parser.types.output;value .qdoc.parser.types.output);

.qdoc.parser.types.output[0Nh]:`$"Any type";
.qdoc.parser.types.output[-0Wh]:`$"Any atom type";
.qdoc.parser.types.output[0h]:`$"Any list type";
.qdoc.parser.types.output[98h]:`Table;
.qdoc.parser.types.output[99h]:`Dictionary;
.qdoc.parser.types.output[100h]:`Function;

