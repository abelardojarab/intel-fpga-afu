#!/usr/bin/env python

import argparse
import os
import sys

from subprocess import (Popen, PIPE)

QUARTUS_ENABLE_TRACE = '''\
proc echo_command {cmd op} { puts $cmd }
proc trace_cmds {cmds} {
    foreach cmd $cmds {
        trace add execution $cmd enter echo_command
    }
}
trace_cmds {project_open project_close set_current_revision set_global_assignment export_assignments}
'''

def quartus_assignment_name(filename):
    ext_map = {
        '.v':    'VERILOG_FILE',
        '.sv':   'SYSTEMVERILOG_FILE',
        '.vh':   'SYSTEMVERILOG_FILE',
        '.svh':  'SYSTEMVERILOG_FILE',
        '.vhd':  'VHDL_FILE',
        '.sdc':  'SDC_FILE',
        '.qsys': 'QSYS_FILE',
        '.json': 'MISC_FILE',
        '.stp' : 'SIGNALTAP_FILE',
    }
    _basename, ext = os.path.splitext(filename)

    if ext in ext_map:
        return ext_map[ext]
    elif os.path.isdir(filename):
        return 'SEARCH_PATH'
    else:
        print "Unrecognized file extension '{0}' ({1})".format(ext, filename)
        raise NotImplementedError

def add_filelist_commands(filelist):
    commands = ''
    with open(filelist) as files:
        for filename in files:
            filename = filename.rstrip('\n')
            commands += 'set_global_assignment -name {0} "{1}"\n'.format(quartus_assignment_name(filename),
                                                                         os.path.join('..', 'afu', filename))
    return commands

def extra_tcl_commands(extra_tcl):
    if extra_tcl:
        return open(extra_tcl).read()
    else:
        return ''

def main(args=None):
    parser = argparse.ArgumentParser(description='Setup afu_synth and afu_fit revisions for a given QPF')
    parser.add_argument('qpf', help='Path of QPF to modify')
    parser.add_argument('filelist', help='List of files to add to afu_synth/afu_fit revisions')
    parser.add_argument('extra_tcl', nargs='?', help='Additional quartus_sh commands to run (optional)')
    opts = parser.parse_args(args)

    command_buffer = '\n'.join([QUARTUS_ENABLE_TRACE,
                                'project_open "{0}"'.format(opts.qpf),
                                'set_current_revision afu_synth',
                                    add_filelist_commands(opts.filelist),
                                    extra_tcl_commands(opts.extra_tcl),
                                    'export_assignments',
                                'set_current_revision afu_fit',
                                    add_filelist_commands(opts.filelist),
                                    extra_tcl_commands(opts.extra_tcl),
                                    'export_assignments',
                                'project_close'])

    # WTF? '-t' doesn't read until EOF, only for two zero-byte read()s
    #proc = Popen(['quartus_sh', '-t', '/dev/stdin'], stdin=PIPE)
    proc = Popen(['quartus_sh', '-s'], stdin=PIPE)
    proc.communicate(command_buffer)
    sys.exit(proc.returncode)

if __name__ == '__main__':
    main()
