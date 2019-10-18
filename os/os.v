module os

#include <sys/stat.h>
const (
	args = []string
)

struct FILE {
}

struct File {
	cfile *FILE
}

import const (
	SEEK_SET
	SEEK_END
)

fn init_os_args(argc int, c voidptr) []string {
	mut args := []string
	# char** argv = (char**) c;
	for i := 0; i < argc; i++ {
		// # printf("ARG %d = '%s'\n", i, argv[i]);
		arg := ''
		# arg = tos(argv[i], strlen(argv[i]));
		args << arg
	}
	# os__args = args;
	return args
}

fn parse_windows_cmd_line(cmd byteptr) {
	s := tos2(cmd)
	vals := s.split(' ')
	println(vals)
	# os__args = vals;
}

// read_file reads the file in `path` and returns the contents.
// TODO return `?string`
pub fn read_file(path string) string {
	res := ''
	# FILE *f = fopen(path.str, "r");
	# if (!f) return tos("", 0);
	# fseek(f, 0, SEEK_END);
	# long fsize = ftell(f);
	// # fseek(f, 0, SEEK_SET);  //same as rewind(f);
	# rewind(f);
	# char *string = malloc(fsize + 1);
	# fread(string, fsize, 1, f);
	# fclose(f);
	# string[fsize] = 0;
	// # printf("RFILE= %s\n", string);
	# res = tos(string, fsize);
	return res
}

fn (f File) read_rune() string {
	# if (!f.cfile) return tos("", 0);
	c := malloc(1)
	C.fread(c, 1, 1, f.cfile)
	return tos(c, 1)
}

// `file_size` returns the size of the file located in `path`.
pub fn file_size(path string) int {
	# struct stat s;
	# stat(path.str, &s);
	// # if (S_ISLNK(s.st_mode)) return -1;
	# return s.st_size;
	// //////////////////////
	# FILE *f = fopen(path.str, "r");
	# if (!f) return 0;
	# fseek(f, 0, SEEK_END);
	# long fsize = ftell(f);
	// # fseek(f, 0, SEEK_SET);  //same as rewind(f);
	# rewind(f);
	# return fsize;
	return 0
}

pub fn file_last_mod_unix(path string) int {
	# struct stat attr;
	# stat(path.str, &attr);
	# return attr.st_mtime ;
	return 0
}

/* 
pub fn file_last_mod_time(path string) time.Time {
	return time.now()
	q := C.tm{}
	# struct stat attr;
	# stat(path.str, &attr);
	// # q = attr.st_mtime;
	# struct tm * now = localtime(&attr.st_mtime);
	# q = *now;
	# printf("Last modified time: %s", ctime(&attr.st_mtime));
	return time.convert_ctime(q)
}
*/
// `read_lines` reads the file in `path` into an array of lines.
pub fn read_lines(path string) []string {
	return read_file_lines(path)
}

fn read_file_into_lines(path string) []string {
	return read_file_lines(path)
}

fn read_file_into_ulines(path string) []ustring {
	lines := read_file_into_lines(path)
	// mut ulines := new_array(0, lines.len, sizeof(ustring))
	mut ulines := []ustring
	for myline in lines {
		// ulines[i] = ustr
		ulines << myline.ustring()
	}
	return ulines
}

const (
	BUF_SIZE = 5000
)

fn read_file_lines(path string) []string {
	// println('read file $path into lines')
	mut res := []string
	# char buf[os__BUF_SIZE];
	# FILE *fp = fopen(path.str, "rb");
	# if (!fp)
	{
		println('failed to open file "$path"')
		return res
	}
	# while (fgets(buf, os__BUF_SIZE, fp) != NULL)
	{
		mut val := ''
		# buf[strlen(buf) - 1] = '\0'; // eat the newline fgets() stores
	#ifdef windows
		# if (buf[strlen(buf)-2] == 13)
		# buf[strlen(buf) - 2] = '\0'; // eat the newline fgets() stores
	#endif
		// # printf("%s\n", buf);
		# val=tos_clone(buf) ;
		// for i := 0; i < val.len; i++ {
		// C.printf('%d) %c %d\n', i, val.str[i], val.str[i])
		// }
	#ifdef windows
		// if val.str[val.len - 1] == 13 {
		if val[val.len - 1] == 13 {
			// TODO
			// val.len--
		}
	#endif
		// println('QQQ read line="$val"')
		res << val
	}
	# fclose(fp);
	return res
}

fn append_to_file(file, s string) {
	# FILE* fp = fopen(file.str, "a");
	# fputs(s.str, fp);
	# fputs("\n", fp);
	# fclose(fp);
}

struct Reader {
	fp *FILE
}

struct FileInfo {
	name string
	size int
}

// fn open(file string) File? {
// return open_file(file)
// }
pub fn open(path string) File {
	return open_file(path)
}

fn open_file(file string) File {
	return create_file2(file, 'r')
}

// `create` creates a file at a specified location and returns a writable `File` object.
pub fn create(path string) File {
	return create_file(path)
}

pub fn open_append(path string) File {
	return create_file(path)
}

fn create_file(file string) File {
	return create_file2(file, 'w')
}

fn create_file_a(file string) File {
	return create_file2(file, 'a')
}

fn open_file_a(file string) File {
	return create_file2(file, 'a')
}

fn create_file2(file string, mode string) File {
	res := File {
		cfile: C.fopen(file.cstr(), mode.cstr())
	}
	if isnil(res.cfile) {
		println('coudlnt create file "$file"')
	}
	return res
}

fn (f File) append(s string) {
	ss := s.clone()
	C.fputs(ss.cstr(), f.cfile)
	// ss.free()
	// C.fwrite(s.str, 1, s.len, f.cfile)
}

// convert any value to []byte (LittleEndian) and write it
// for example if we have write(7, 4), "07 00 00 00" gets written
// write(0x1234, 2) => "34 12"
fn (f File) write(data voidptr, size int) {
	C.fwrite(data, 1, size, f.cfile)
}

fn (f File) write_at(data voidptr, size, pos int) {
	C.fseek(f.cfile, pos, SEEK_SET)
	C.fwrite(data, 1, size, f.cfile)
	C.fseek(f.cfile, 0, SEEK_END)
}

fn (f File) appendln(s string) {
	// C.fwrite(s.str, 1, s.len, f.cfile)
	// ss := s.clone()
	// TODO perf
	C.fputs(s.cstr(), f.cfile)
	// ss.free()
	C.fputs('\n', f.cfile)
}

fn (f File) close() {
	C.fclose(f.cfile)
}

fn close_file(fp *FILE) {
	$if windows {
	}
	# if (fp)
	C.fclose(fp)
}

// `system2` starts the specified command, waits for it to complete, and returns its code.
pub fn system2(cmd string) int {
	cstr := cmd.clone()
	ret := int(C.system(cstr.cstr()))
	// println(' system2 ret=$ret cmd="$s"')
	if ret == -1 {
		os.print_c_errno()
	}
	return ret
}

fn popen(path string) *FILE {
	cpath := path.cstr()
	$if windows {
		return C._popen(cpath, 'r')
	}
	$else {
		return C.popen(cpath, 'r')
	}
}

// TODO rename to run or exec (system doesnt return  a string)
// `system` starts the specified command, waits for it to complete, and returns its output.
// TODO merge the two functions.
pub fn system(cmd string) string {
	// println('OS SYSTEM($s)')
	res := ''
	ss := '$cmd 2>&1'
	_ := 0// TODO DOLLAR TOKEN
	f := popen(ss)// cmd)
	// # if (!f)
	if isnil(f) {
		println('popen $cmd failed')
	}
	#define MAX 1000
	# char buf[MAX];
	// # char* buf = malloc(MAX);
	// j# sleep(1);
	// # if (!fgets(buf, MAX, f)) {
	// jprintln('first get failed')
	// jos.print_c_errno()
	// j# }
	# while (fgets(buf, MAX, f) != NULL)  {
	// # printf("popen buf=%s\n", buf);
	# res = string_add(res, tos(buf, strlen(buf)));
	# }
	// println(res)
	return res.trim_space()
}

fn system_into_lines(s string) []string {
	mut res := []string
	cmd := '$s 2>&1'
#ifdef windows
	# FILE* f = _popen(cmd.str, "r");
#else
	# FILE* f = popen(cmd.str, "r");
#endif
	#define MAX 5000
	// # char buf[MAX];
	# char * buf = malloc(sizeof(char) * MAX);
	# while (fgets(buf, MAX, f) != NULL)
	{
		val := ''
		# buf[strlen(buf) - 1] = '\0'; // eat the newline fgets() stores
		# val=tos_clone(buf);
		res << val
	}
	return res
}

// `getenv` returns the value of the environment variable named by the key.
pub fn getenv(key string) string {
	s := C.getenv(key.cstr())
	if isnil(s) {
		return ''
	}
	return tos2(s)
}

fn exit(reason string) {
	println2('exit(): $reason')
	log(reason)
	C.exit(0)
}

fn exit1(reason string) {
	println2('exit(): $reason')
	C.exit(1)
}

// `file_exists` returns true if `path` exists.
pub fn file_exists(path string) bool {
	// # return access( path.str, F_OK ) != -1 ;
	res := false
#ifdef windows
	# res = _access( path.str, 0 ) != -1 ;
#else
	# res = access( path.str, 0 ) != -1 ;
#endif
	return res
}

// `mkdir` creates a new directory with the specified path.
pub fn mkdir(path string) {
	$if windows {
		path = path.replace('/', '\\')
		C.CreateDirectory(path.cstr(), 0)
	}
	$else {
		println('AAAAAAAA $$ "$path"')
		C.mkdir(path.cstr(), 511)// S_IRWXU | S_IRWXG | S_IRWXO
		// os.system2('mkdir -p $path')
	}
}

// `rm` removes file in `path`.
pub fn rm(path string) {
	$if windows {
		// os.system2('del /f $path')
	}
	$else {
		C.remove(path.cstr())
	}
	// C.unlink(path.cstr())
}

fn rmdir(path string, guard string) {
	if !path.contains(guard) {
		println('rmdir canceled because the path doesnt contain $guard')
		return
	}
	println2('rmdir "$path"')
#ifndef windows
	os.system('rm -rf "$path"')
#else
	os.system('rmdir /s /q "$path"')
#endif
}

pub fn unzip(path, out string) {
	$if windows {
		// TODO native string
		// TODO handle older Windows
		// The only way to unzip a file without installing dependencies is to use PowerShell + .NET
		# char *s="powershell.exe -nologo -noprofile -command \"& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('PATH', 'OUT'); }\" ";
		mut cmd := ''
		# cmd = tos(s, strlen(s));
		cmd = cmd.replace('PATH', path)
		cmd = cmd.replace('OUT', out)
		os.system(cmd)
	}
	$else {
		os.system('unzip -o -d "$out" "$path"')
	}
}

fn print_c_errno() {
	# printf("errno=%d err='%s'\n", errno, strerror(errno));
}

pub fn basedir(path string) string {
	pos := path.last_index('/')
	if pos == -1 {
		return path
	}
	return path.left(pos + 1)
}

pub fn filename(path string) string {
	return path.all_after('/')
}

fn C.getline(voidptr, voidptr, voidptr) int

pub fn get_line() string {
	max := 256
	buf := malloc(max)
	nr_chars := C.getline(&buf, &max, stdin)
	if nr_chars == 0 {
		return ''
	}
	return tos(buf, nr_chars - 1)
}

pub fn user_os() string {
	$if linux {
		return 'linux'
	}
	$if mac {
		return 'mac'
	}
	$if windows {
		return 'windows'
	}
	return 'unknown'
}

// `home_dir` returns path to user's home directory.
pub fn home_dir() string {
	mut home := os.getenv('HOME')
	$if windows {
		home = os.getenv('HOMEDRIVE')
		home += os.getenv('HOMEPATH')
	}
	home += '/'
	return home
}

pub fn write_file(path, text string) {
	f := os.create(path)
	f.appendln(text)
	f.close()
}

fn on_segfault(f voidptr) {
#ifdef windows
	return
#endif
#ifdef mac
	# struct sigaction sa;
	# memset(&sa, 0, sizeof(struct sigaction));
	# sigemptyset(&sa.sa_mask);
	# sa.sa_sigaction = f;
	# sa.sa_flags   = SA_SIGINFO;
	# sigaction(SIGSEGV, &sa, 0);
#endif
}

