Class Simple.ZFwrapper Extends %RegisteredObject [ Language = objectscript ]
{

/// Simple wrapper for $zf(-100). This reduces our reliance on <class>%Studio.SourceControl.ISC</class>.
ClassMethod RunCmd(Command As %String, ByRef args, ByRef Output) As %Status
{
 set errortext = ""
 #dim status as %Status = $$$OK
 set outfile = ##class(%File).TempFilename("out"), 
 errfile = ##class(%File).TempFilename("err")
 try
 {
 set rc = $zf(-100,"/STDOUT="""_outfile_"""/STDERR="""_errfile_"""", Command, .args)
 }
 catch 
 {
 return $$$ERROR($$$FileDoesNotExist, Command)
 }
 set outstream = ##class(%Stream.FileCharacter).%New(), errstream = ##class(%Stream.FileCharacter).%New()
 do errstream.LinkToFile(errfile)
 if (errstream.Size>0)
 {
 while 'errstream.AtEnd
 {
 set line = errstream.ReadLine()
 set errortext = errortext_line
 }
 set status = $$$ERROR($$$GeneralError,errortext)
 }
 
 do outstream.LinkToFile(outfile)
 while 'outstream.AtEnd
 {
 set line = outstream.ReadLine()
 set Output($increment(Output)) = line
 }
 do ##class(%File).Delete(outfile)
 do ##class(%File).Delete(errfile)
 quit status
}

}
