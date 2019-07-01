
# Fiddler mock jsonp response

```cs
public static void OnBeforeResponse(Session oSession)
{
    if(oSession.url.IndexOf("/rcm/RelativeRecommend/seriesrecommend") != -1){
        oSession.utilDecodeResponse();
        string method = "";
        int startIndex = oSession.url.IndexOf("&callback=");
        if(startIndex != -1){
            startIndex += 10;
            int endIndex = oSession.url.IndexOf("&", startIndex + 1);
            if(endIndex == -1){
                endIndex = oSession.url.Length;
            }
            method = oSession.url.Substring(startIndex, endIndex - startIndex);
        }
        
        var body = method + "(" + oSession.GetResponseBodyAsString() + ")";
        oSession.utilSetResponseBody(body);
    }
}
```

可以借助 Fiddler AutoResponder 返回本地文件.