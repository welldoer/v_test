module main

struct CGen {
	out          os.File
	out_path     string
	typedefs     []string
	type_aliases []string
	includes     []string
	types        []string
	thread_args  []string
	thread_fns   []string
	consts       []string
	fns          []string
	so_fns       []string
	consts_init  []string
	// tmp_lines                        []string
	// tmp_lines_pos     int
	lines        []string
	is_user      bool
mut:
	run          Pass
	nogen        bool
	tmp_line     string
	cur_line     string
	prev_line    string
	is_tmp       bool
	fn_main      string
	stash        string
	// st_start_pos     int
}

fn new_cgen(out_name_c string) *CGen {
	// println('NEW CGENN($out_name_c)')
	// println('$LANG_TMP/$out_name_c')
	gen := &CGen {
		out_path: '$TmpPath/$out_name_c'
		out: os.create_file('$TmpPath/$out_name_c')
	}
	for i := 0; i < 10; i++ {
		// gen.tmp_lines.push('')
	}
	return gen
}

fn (g mut CGen) genln(s string) {
	if g.nogen || g.run == RUN_DECLS {
		return
	}
	if g.is_tmp {
		// if g.tmp_lines_pos > 0 {
		g.tmp_line = '$g.tmp_line $s\n'
		return
	}
	g.cur_line = '$g.cur_line $s'
	if g.cur_line != '' {
		g.lines << g.cur_line
		g.prev_line = g.cur_line
		g.cur_line = ''
	}
	// g.lines << s
}

fn (g mut CGen) gen(s string) {
	// if g.nogen || g.run == RunType.RUN_DECLS {
	if g.nogen || g.run == RUN_DECLS {
		return
	}
	if g.is_tmp {
		// if g.tmp_lines_pos > 0 {
		g.tmp_line = '$g.tmp_line $s'
	}
	else {
		g.cur_line = '$g.cur_line $s'
	}
}

fn (g mut CGen) save() {
	s := g.lines.join('\n')
	g.out.appendln(s)
	g.out.close()
	// os.system('clang-format -i $g.out_path')
}

fn (g mut CGen) start_tmp() {
	if g.is_tmp {
		println(g.tmp_line)
		os.exit('start_tmp() already started. cur_line="$g.cur_line"')
	}
	// kg.tmp_lines_pos++
	g.tmp_line = ''
	// g.tmp_lines[g.tmp_lines_pos]  = ''
	// g.tmp_lines.set(g.tmp_lines_pos, '')
	g.is_tmp = true
}

fn (g mut CGen) end_tmp() string {
	g.is_tmp = false
	res := g.tmp_line
	g.tmp_line = ''
	// g.tmp_lines_pos--
	// g.tmp_line = g.tmp_lines[g.tmp_lines_pos]
	return res
}

fn (g mut CGen) add_placeholder() int {
	// g.genln('/*placeholder*/')
	// g.genln('')
	// return g.lines.len - 1
	if g.is_tmp {
		return g.tmp_line.len
	}
	return g.cur_line.len
}

fn (g mut CGen) set_placeholder(pos int, val string) {
	if g.nogen {
		return
	}
	// g.lines.set(pos, val)
	if g.is_tmp {
		left := g.tmp_line.left(pos)
		right := g.tmp_line.right(pos)
		g.tmp_line = '${left}${val}${right}'
		return
	}
	left := g.cur_line.left(pos)
	right := g.cur_line.right(pos)
	g.cur_line = '${left}${val}${right}'
	// g.genln('')
}

// /////////////////////
fn (g mut CGen) add_placeholder2() int {
	if g.is_tmp {
		exit('tmp in addp2')
	}
	g.lines << ''
	return g.lines.len - 1
}

fn (g mut CGen) set_placeholder2(pos int, val string) {
	if g.nogen {
		return
	}
	if g.is_tmp {
		exit('tmp in setp2')
	}
	g.lines[pos] = val
}

// /////////////////
// fn (g mut CGen) cut_lines_after(pos int) string {
// end := g.lines.len
// lines := g.lines.slice_fast(pos, end)
// body := lines.join('\n')
// g.lines = g.lines.slice_fast(0, pos)
// return body
// }
// fn (g mut CGen) set_prev_line(val string) {
// g.lines.set(g.lines.len - 3, val)
// }
// ////fn (g mut CGen) go_back() {
// ////g.stash = g.prev_line + g.cur_line
// g.lines.set(g.lin
// ////}
// fn (g mut CGen) end_statement() {
// last_lines := g.lines.slice_fast(g.st_start_pos, g.lines.len - 1)
// mut merged := last_lines.join(' ')
// merged += '/* M $last_lines.len */'
// merged = merged.replace('\n', '')
// // zero last N lines instead of deleting them
// for i := g.st_start_pos; i < g.lines.len; i++ {
// g.lines.set(i, '')
// }
// g.lines.set(g.lines.len - 1, merged)
// // g.genln('')
// g.st_start_pos = g.lines.len - 1
// // os.exitkmerged)
// }
// fn (g mut CGen) prepend_type(typ string) {
// g.cur_line = typ.add(g.cur_line)
// g.cur_line='!!!'
// }
fn (g mut CGen) insert_before(val string) {
	// g.cur_line = val.add(g.cur_line)
	// return
	// val += '/*inserted*/'
	g.lines.insert(g.lines.len - 1, val)
}

// fn (g mut CGen) swap_last_lines() {
// return
// if g.run == RUN_DECLS {
// return
// }
// i := g.lines.len - 1
// j := i - 1
// tmp := g.lines[i]
// // println('lines i = $tmp')
// // println('lines j = ${g.lines[j]}')
// // // os.exit('')
// g.lines.set(i, g.lines[j])
// g.lines.set(j, tmp)
// }
fn (g mut CGen) register_thread_fn(wrapper_name, wrapper_text, struct_text string) {
	for arg in g.thread_args {
		if arg.contains(wrapper_name) {
			return
		}
	}
	g.thread_args << struct_text
	g.thread_args << wrapper_text
}

/* 
fn (g mut CGen) delete_all_after(pos int) {
	if pos > g.cur_line.len - 1 {
		return
	}
	g.cur_line = g.cur_line.substr(0, pos)
}
*/
fn (c mut V) prof_counters() string {
	mut res := []string
	// Global fns
	for f in c.table.fns {
		res << 'double ${c.table.cgen_name(f)}_time;'
		// println(f.name)
	}
	// Methods
	for typ in c.table.types {
		// println('')
		for f in typ.methods {
			// res << f.cgen_name()
			res << 'double ${c.table.cgen_name(f)}_time;'
			// println(f.cgen_name())
		}
	}
	return res.join(';\n')
}

fn (p mut Parser) print_prof_counters() string {
	mut res := []string
	// Global fns
	for f in p.table.fns {
		counter := '${p.table.cgen_name(f)}_time'
		res << 'if ($counter) printf("%%f : $f.name \\n", $counter);'
		// println(f.name)
	}
	// Methods
	for typ in p.table.types {
		// println('')
		for f in typ.methods {
			counter := '${p.table.cgen_name(f)}_time'
			res << 'if ($counter) printf("%%f : ${p.table.cgen_name(f)} \\n", $counter);'
			// res << 'if ($counter) printf("$f.name : %%f\\n", $counter);'
			// res << f.cgen_name()
			// res << 'double ${f.cgen_name()}_time;'
			// println(f.cgen_name())
		}
	}
	return res.join(';\n')
}

fn (p mut Parser) gen_type(s string) {
	if !p.first_run() {
		return
	}
	p.cgen.types << s
}

fn (p mut Parser) gen_typedef(s string) {
	if !p.first_run() {
		return
	}
	p.cgen.typedefs << s
}

fn (p mut Parser) gen_type_alias(s string) {
	if !p.first_run() {
		return
	}
	p.cgen.type_aliases << s
}

fn (g mut CGen) add_to_main(s string) {
	println('add to main')
	g.fn_main = g.fn_main + s
}

