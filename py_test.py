#!/usr/bin/env python

# Copyright 2008-2009 WebDriver committers
# Copyright 2008-2009 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""A script for running the unit test and example tests for the python
binding."""

import os
import shutil
import subprocess

def run_script(script_name, *args):
    return subprocess.Popen("python %s %s" %
                            (script_name.replace("/", os.path.sep),
                             " ".join(args)), shell=True)

if __name__ == "__main__":
    os.environ["WEBDRIVER"] = "."
    os.environ["WEBDRIVER_EXT"] = os.path.join("build",
                                               "webdriver-extension.zip")
    os.environ["PYTHONPATH"] = os.pathsep.join([os.environ.get("PYTHONPATH", ""),
                                             os.path.join("firefox", "lib-src"),
                                             os.path.join("build", "lib")])
    run_script("setup.py", "build").wait()
    try:
        for test in ["api_examples", "cookie_tests", "firefox_launcher_tests"]:
            process = run_script("firefox/test/py/%s.py" % test)
            assert process.wait() == 0, "Test %s failed" % test
    finally:
        shutil.rmtree("build/lib")
        try:
            os.kill(process.pid, 9)
        except:
            pass
