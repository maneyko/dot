"""
Define magic command to save session history to log file.

https://ipython.readthedocs.io/en/stable/interactive/tutorial.html#startup-files
https://ipython.readthedocs.io/en/stable/config/custommagics.html
"""

import os
import sys
import time
import atexit
import contextlib
from IPython import get_ipython
from IPython.core.magic import register_line_magic

HOME = os.environ['HOME']
ipython = get_ipython()

@contextlib.contextmanager
def suppress_stdout():
    with open(os.devnull, 'w') as devnull:
        old_stdout = sys.stdout
        sys.stdout = devnull
        try:
            yield
        finally:
            sys.stdout = old_stdout

@register_line_magic
def saveall(line, exit=False):
    """Saves entire history of session to log file."""
    logs = os.path.join(HOME, '.ipython/profile_maneyko/logs')
    ninputs = ipython.run_cell('len(In)').result
    if not os.path.isdir(logs):
        os.makedirs(logs)
    if exit == True:
        history =  ninputs - 1
    else:  # Don't include magic command in log
        history =  ninputs - 2
    timestamp = time.strftime('%Y-%m-%d_@_%H:%M:%S')
    logfile = os.path.join(logs, timestamp) + '.py'
    with suppress_stdout():
        ipython.magic('save {} 1-{:d}'.format(logfile, history))

atexit.register(saveall, line=None, exit=True)
