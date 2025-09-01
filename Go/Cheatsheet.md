# 🐹 Go Interfaces & Structs Cheat Sheet  

## 1. **I/O Core Interfaces (io, os, bytes, strings)**

| Interface   | Method(s)                               | Common Structs That Implement It          | Usage                         |
|-------------|------------------------------------------|--------------------------------------------|-------------------------------|
| `io.Reader` | `Read(p []byte) (n int, err error)`     | `*os.File`, `*bytes.Buffer`, `*strings.Reader`, `net.Conn` | Read bytes from file, buffer, network |
| `io.Writer` | `Write(p []byte) (n int, err error)`    | `*os.File`, `*bytes.Buffer`, `net.Conn`, `gzip.Writer` | Write bytes to file, buffer, network |
| `io.Closer` | `Close() error`                         | `*os.File`, `net.Conn`, `http.Response.Body` | Free resources |
| `io.Seeker` | `Seek(offset int64, whence int)`        | `*os.File`                                 | Random access in files |
| `io.ReaderFrom` | `ReadFrom(r Reader) (n int64, err error)` | `*bytes.Buffer` | Optimized copy |

👉 **Tip**: Most stdlib functions work with `io.Reader`/`io.Writer`, not concrete structs. That’s why you can `io.Copy` between files, HTTP bodies, buffers, etc.

---

## 2. **String & Formatting Interfaces**

| Interface      | Method(s)        | Common Implementations | Usage |
|----------------|------------------|------------------------|-------|
| `fmt.Stringer` | `String() string` | `time.Time`, `url.URL`, custom types | Controls `fmt.Println`, `%s` formatting |
| `error`        | `Error() string`  | `errors.New(...)`, `fmt.Errorf`, custom error types | Go’s universal error handling |

👉 **Tip**: If you want your type to print nicely, implement `String()`. If you want it to be usable in `if err != nil`, implement `Error()`.

---

## 3. **HTTP (net/http)**

| Interface            | Method(s)                               | Common Implementations | Usage |
|----------------------|------------------------------------------|------------------------|-------|
| `http.Handler`       | `ServeHTTP(w ResponseWriter, r *Request)` | `http.ServeMux`, `http.HandlerFunc`, your custom struct | Core of web server routing |
| `http.ResponseWriter`| `Header() http.Header`, `Write([]byte)`, `WriteHeader(int)` | Provided by server | Used to send response back |
| `http.RoundTripper`  | `RoundTrip(*Request) (*Response, error)` | `http.Transport` | Customizing HTTP clients |
| `http.HandlerFunc`   | Adapter: `func(ResponseWriter, *Request)` → Handler | Wraps functions directly | Handy for small handlers |

👉 **Tip**: Any function with signature `func(http.ResponseWriter, *http.Request)` can be turned into an `http.Handler` using `http.HandlerFunc`.

---

## 4. **Concurrency (sync, context)**

| Interface / Struct | Methods | Usage |
|--------------------|---------|-------|
| `context.Context` (interface) | `Deadline()`, `Done()`, `Err()`, `Value()` | Cancellation, deadlines, request-scoped values |
| `sync.Mutex` (struct) | `Lock()`, `Unlock()` | Protect shared data |
| `sync.WaitGroup` (struct) | `Add()`, `Done()`, `Wait()` | Wait for goroutines to finish |
| `sync.Once` (struct) | `Do(func())` | Run code exactly once |

👉 **Tip**: You’ll see `ctx context.Context` as the first param in many functions in stdlib and libraries.

---

## 5. **Networking (net, net/http, net.Conn)**

| Interface    | Method(s) | Common Implementations | Usage |
|--------------|-----------|------------------------|-------|
| `net.Conn`   | `Read`, `Write`, `Close`, `LocalAddr`, `RemoteAddr` | `TCPConn`, `UDPConn` | Represents a network connection |
| `net.Listener` | `Accept() (Conn, error)`, `Close()`, `Addr()` | `TCPListener` | Accepts new network connections |

---

## 6. **Filesystem (os, io/fs)**

| Interface | Method(s) | Common Structs | Usage |
|-----------|-----------|----------------|-------|
| `fs.FS`   | `Open(name string) (fs.File, error)` | `os.DirFS`, `embed.FS` | Read-only file system |
| `fs.File` | `Stat()`, `Read()`, `Close()` | `*os.File` | Abstraction over files |
| `os.File` (struct) | Implements Reader, Writer, Seeker, Closer | Open files on disk |

---

## 7. **Database (database/sql)**

| Interface | Method(s) | Common Structs | Usage |
|-----------|-----------|----------------|-------|
| `sql.Scanner` | `Scan(src any) error` | `sql.NullString`, `sql.NullInt64` | Reading SQL into Go types |
| `driver.Valuer` | `Value() (driver.Value, error)` | Custom types | Writing Go values into SQL |

---

## 🛠️ Patterns You’ll See Again and Again

1. **Small Interfaces**  
   - `io.Reader` (just 1 method!)  
   - Easy to satisfy with many structs.  

2. **Adapters**  
   - `http.HandlerFunc` wraps functions into interfaces.  

3. **Structs with Unexported Fields**  
   - e.g. `http.Server` has unexported fields → use provided methods, not direct access.  

4. **Interface Composition**  
   - `io.ReadWriter` = `Reader + Writer`.  

---

## ⚡ Pro Tips to Read Go Docs

- **When you see a function arg of type `interface`** → look at methods required → find structs that implement it.  
- **When you see a return type of `struct`** → look at its methods to see what interfaces it satisfies.  
- **Follow the chain**: function → interface → struct.  
