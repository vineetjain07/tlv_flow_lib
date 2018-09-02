\m4_TLV_version 1d: tl-x.org
\SV
/*
Copyright (c) 2018, Steven F. Hoover

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * The name of Steven F. Hoover
      may not be used to endorse or promote products derived from this software
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// The array size should be defined by, eg:
// m4_define_hier(M4_ENTRIES, 1024)
// Can write transaction (/_trans$ANY) or signal. If writing a signal, include signal range.
// Write from |_wr@_wr and read data written last cycle into |_rd@_rd.
// For naturally-aligned rd/wr pipelines (rd transaction reflects data of stage-aligned wr transaction), @_rd would be @_wr + 1.
// Functionality is preserved if @_rd and @_wr are changed by the same amount.
\TLV array1r1w(/_top, /_entries, |_wr, @_wr, $_wr_en, $_wr_addr, |_rd, @_rd, $_rd_en, $_rd_addr, $_data, /_trans)
   // Write Pipeline
   // The array entries hierarchy (needs a definition to define range, and currently, /_trans declaration required before reference).
   /m4_echo(M4_['']m4_to_upper(m4_strip_prefix(/_entries))_HIER)
      /_trans
         
   // Write transaction to cache
   // (TLV assignment syntax prohibits assignment outside of it's own scope, but \SV_plus does not.)
   \SV_plus
      always_comb
         if (|_wr>>m4_stage_eval(@_wr - 0)$_wr_en)
            /_entries[|_wr>>m4_stage_eval(@_wr - 0)$_wr_addr]/_trans$['']$_data = |_wr/_trans>>m4_stage_eval(@_wr - 0)$_data;
   
   // Read Pipeline
   |_rd
      @_rd
         // Read transaction from cache.
         ?$rd_en
            /_trans
            m4_ifelse(/_trans, [''], [''], ['   '])$_data = /_top/_entries[|rd$_rd_addr]/_trans>>m4_stage_eval(1 - @_rd)$_data;