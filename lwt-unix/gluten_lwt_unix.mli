(*----------------------------------------------------------------------------
 *  Copyright (c) 2019-2020 António Nuno Monteiro
 *
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *
 *  3. Neither the name of the copyright holder nor the names of its
 *  contributors may be used to endorse or promote products derived from this
 *  software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 *---------------------------------------------------------------------------*)

module Server : sig
  include
    Gluten_lwt.Server
      with type socket = Lwt_unix.file_descr
       and type addr = Unix.sockaddr

  module TLS : sig
    include
      Gluten_lwt.Server
        with type socket = Tls_io.descriptor
         and type addr = Unix.sockaddr

    val create_full
      :  ?ciphers:Tls.Ciphersuite.ciphersuite list
      -> ?version:(Tls.Core.tls_version * Tls.Core.tls_version)
      -> ?signature_algorithms:Tls.Core.signature_algorithm list
      -> ?reneg:bool
      -> ?certificates:Tls.Config.own_cert
      -> ?acceptable_cas:X509.Distinguished_name.t list
      -> ?authenticator:X509.Authenticator.t
      -> ?alpn_protocols:string list
      -> ?zero_rtt:int32
      -> ?ip:Ipaddr.t
      -> Unix.sockaddr
      -> Lwt_unix.file_descr
      -> socket Lwt.t

    val create_default
      :  ?alpn_protocols:string list
      -> certfile:string
      -> keyfile:string
      -> Unix.sockaddr
      -> Lwt_unix.file_descr
      -> socket Lwt.t
  end

  module SSL : sig
    include
      Gluten_lwt.Server
        with type socket = Ssl_io.descriptor
         and type addr = Unix.sockaddr

    val create_default
      :  ?alpn_protocols:string list
      -> certfile:string
      -> keyfile:string
      -> Unix.sockaddr
      -> Lwt_unix.file_descr
      -> socket Lwt.t
  end
end

(* For an example, see [examples/lwt_get.ml]. *)
module Client : sig
  include Gluten_lwt.Client with type socket = Lwt_unix.file_descr

  module TLS : sig
    include Gluten_lwt.Client with type socket = Tls_io.descriptor

    val create_full
      :  X509.Authenticator.t
      -> ?peer_name:[ `host ] Domain_name.t
      -> ?ciphers:Tls.Ciphersuite.ciphersuite list
      -> ?version:(Tls.Core.tls_version * Tls.Core.tls_version)
      -> ?signature_algorithms:Tls.Core.signature_algorithm list
      -> ?reneg:bool
      -> ?certificates:Tls.Config.own_cert
      -> ?alpn_protocols:string list
      -> ?ip:Ipaddr.t
      -> Lwt_unix.file_descr
      -> socket Lwt.t

    val create_default
      :  ?alpn_protocols:string list
      -> Lwt_unix.file_descr
      -> socket Lwt.t
  end

  module SSL : sig
    include Gluten_lwt.Client with type socket = Ssl_io.descriptor

    val create_default
      :  ?alpn_protocols:string list
      -> Lwt_unix.file_descr
      -> socket Lwt.t
  end
end
