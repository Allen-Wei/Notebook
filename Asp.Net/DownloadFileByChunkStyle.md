##在ASP.Net以流的方式下载文件
在ASP.Net MVC中有一个FileStreamResult的ActionResult实现(其实FileStreamResult, FilePathResult, FileContentResult都是FileResult的子类, 而FileResult又是ActionResult的子类.), 一般这个被用来以流的方式下载文件. 可是查看一下源码, 也试了一下发现好像都是先把文件加载到内容, 然后再一次发送到客户端, 这个缺点多多.

下面是FileResult重写ActionResult的ExecuteResult方法:

	public override void ExecuteResult(ControllerContext context)
	{
	    if (context == null)
	    {
	        throw new ArgumentNullException("context");
	    }
	
	    HttpResponseBase response = context.HttpContext.Response;
	    response.ContentType = ContentType;
	
	    if (!String.IsNullOrEmpty(FileDownloadName))
	    {
	    }
	
	    WriteFile(response);	//这个是留给子类(FileStreamResult)去重写实现的.
	}


下面是FileStreamResult重写FileResult的WriteFile方法:

	protected override void WriteFile(HttpResponseBase response)
	{
	    // grab chunks of data and write to the output stream
	    Stream outputStream = response.OutputStream;
	    using (FileStream)
	    {
	        byte[] buffer = new byte[BufferSize];
	
	        while (true)
	        {
	            int bytesRead = FileStream.Read(buffer, 0, BufferSize);
	            if (bytesRead == 0)
	            {
	                // no more data
	                break;
	            }
	
	            outputStream.Write(buffer, 0, bytesRead);
	        }
	    }
	}

看源码貌似是把文件全部加载到内容然后输出.

然后到网上搜了一下如何下载大文件:
[Streaming MP3 Chunks on ASP.NET](http://stackoverflow.com/questions/19403593/streaming-mp3-chunks-on-asp-net) 这是StackOverflow上提问如果以流的方式传输音频:

	Response.BufferOutput = false; //sets chunked encoding
    Response.ContentType = "audio/mpeg";
    using (var bw = new BinaryWriter(Response.OutputStream))
    {
        foreach (DataChunk leChunk in db.Mp3Files.First(mp3 => mp3.Mp3ResourceId.Equals(id)).Data.Chunks.OrderBy(chunk => chunk.ChunkOrder))
        {
            if (Response.IsClientConnected) //avoids the host closed the connection exception
            {
                bw.Write(leChunk.Data); 
            }
        }
    }

另外还需要在web.config中加一个配置:

	<system.webServer>
		<asp enableChunkedEncoding="true" />
	</system.webServer>


[How to Download Large Files from ASP.NET Web Forms or MVC?](http://www.codeproject.com/Tips/842832/How-to-Download-Large-Files-from-ASP-NET-Web-Forms) 这个示例就更为丰富了

	/// <summary>
	/// Download Large Files! For example more than 100MB!
	/// </summary>
	public void Download(int id)
	{
	    // **************************************************
	    string strFileName =
	        string.Format("{0}.zip", id);
	
	    string strRootRelativePathName =
	        string.Format("~/App_Data/Files/{0}", strFileName);
	
	    string strPathName =
	        Server.MapPath(strRootRelativePathName);
	
	    if (System.IO.File.Exists(strPathName) == false)
	    {
	        return;
	    }
	    // **************************************************
	
	    System.IO.Stream oStream = null;
	
	    try
	    {
	        // Open the file
	        oStream =
	            new System.IO.FileStream
	                (path: strPathName,
	                mode: System.IO.FileMode.Open,
	                share: System.IO.FileShare.Read,
	                access: System.IO.FileAccess.Read);
	
	        // **************************************************
	        Response.Buffer = false;
	
	        // Setting the unknown [ContentType]
	        // will display the saving dialog for the user
	        Response.ContentType = "application/octet-stream";
	
	        // With setting the file name,
	        // in the saving dialog, user will see
	        // the [strFileName] name instead of [download]!
	        Response.AddHeader("Content-Disposition", "attachment; filename=" + strFileName);
	
	        long lngFileLength = oStream.Length;
	
	        // Notify user (client) the total file length
	        Response.AddHeader("Content-Length", lngFileLength.ToString());
	        // **************************************************
	
	        // Total bytes that should be read
	        long lngDataToRead = lngFileLength;
	
	        // Read the bytes of file
	        while (lngDataToRead > 0)
	        {
	            // The below code is just for testing! So we commented it!
	            //System.Threading.Thread.Sleep(200);
	
	            // Verify that the client is connected or not?
	            if (Response.IsClientConnected)
	            {
	                // 8KB
	                int intBufferSize = 8 * 1024;
	
	                // Create buffer for reading [intBufferSize] bytes from file
	                byte[] bytBuffers =
	                    new System.Byte[intBufferSize];
	
	                // Read the data and put it in the buffer.
	                int intTheBytesThatReallyHasBeenReadFromTheStream =
	                    oStream.Read(buffer: bytBuffers, offset: 0, count: intBufferSize);
	
	                // Write the data from buffer to the current output stream.
	                Response.OutputStream.Write
	                    (buffer: bytBuffers, offset: 0,
	                    count: intTheBytesThatReallyHasBeenReadFromTheStream);
	
	                // Flush (Send) the data to output
	                // (Don't buffer in server's RAM!)
	                Response.Flush();
	
	                lngDataToRead =
	                    lngDataToRead - intTheBytesThatReallyHasBeenReadFromTheStream;
	            }
	            else
	            {
	                // Prevent infinite loop if user disconnected!
	                lngDataToRead = -1;
	            }
	        }
	    }
	    catch { }
	    finally
	    {
	        if (oStream != null)
	        {
	            //Close the file.
	            oStream.Close();
	            oStream.Dispose();
	            oStream = null;
	        }
	        Response.Close();
	    }
	}


本以为上述能解决大文件下载的问题, 下面是我写的代码:

	public void ProcessRequest(HttpContext context)
	{
		var rep = context.Response;
		var svr = context.Server;
		rep.Clear();
		rep.BufferOutput = false;
		rep.ContentType = "application/iso";
		rep.Headers.Add("Content-Disposition", "attachment; filename=SQLServer2008.iso");
		var fileStream = new FileStream(svr.MapPath("~/Content/SQLServer2008.iso"), FileMode.Open, FileAccess.Read, FileShare.Read);
		long dataLeftLength = fileStream.Length;
		while (dataLeftLength > 0)
		{
			if (rep.IsClientConnected)
			{
				const int chunkLength = 8*1024;
				var buffer = new byte[chunkLength];
				var reallyReadBufferCount = fileStream.Read(buffer, 0, chunkLength);
				rep.OutputStream.Write(buffer, 0, reallyReadBufferCount);
				rep.Flush();
				dataLeftLength = dataLeftLength - reallyReadBufferCount;
			}
			else
			{
				dataLeftLength = -1;
			}
		}
		fileStream.Close();
		fileStream.Dispose();
		rep.Close();
	}

结果小文件是流传送方式了, 可是大文件还是抛出内存溢出异常.
