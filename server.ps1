$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:8080/')
$listener.Start()
$root = $PSScriptRoot
$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.js'   = 'text/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.css'  = 'text/css; charset=utf-8'
  '.png'  = 'image/png'
  '.ico'  = 'image/x-icon'
}
while ($listener.IsListening) {
  try { $ctx = $listener.GetContext() } catch { break }
  $url = $ctx.Request.Url.AbsolutePath
  if ($url -eq '/') { $url = '/index.html' }
  $rel = [Uri]::UnescapeDataString($url.TrimStart('/'))
  $path = Join-Path $root $rel
  if (Test-Path $path -PathType Leaf) {
    $ext = [IO.Path]::GetExtension($path)
    if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] } else { $ctx.Response.ContentType = 'application/octet-stream' }
    $bytes = [IO.File]::ReadAllBytes($path)
    $ctx.Response.ContentLength64 = $bytes.Length
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $ctx.Response.StatusCode = 404
  }
  $ctx.Response.Close()
}
