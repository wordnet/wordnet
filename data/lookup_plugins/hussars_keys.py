# Copyright 2014 Tymon Tobolski
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


from ansible import utils, errors

import httplib

class LookupModule (object):
    def __init__(self, basedir=None, **kwargs):
        self.basedir = basedir

    def run(self, terms, inject=None, **kwargs):
        terms = utils.listify_lookup_plugin_terms(terms, self.basedir, inject)
        if not isinstance(terms, list):
            terms = [terms]

        ret = []

        conn = httplib.HTTPConnection(host='keys.hussa.rs', timeout=30)

        for term in terms:
            conn.request('GET', '/' + term + 'asda')
            resp = conn.getresponse()
            if resp.status == httplib.OK:
                ret.append(resp.read())
            else:
             raise errors.AnsibleError("public hussa.rs key %r not found" % (term,))
        return ret
