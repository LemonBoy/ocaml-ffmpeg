(** Common code shared across all FFmpeg libraries. *)

(** {1 Line} *)

type input
type output


(** {1 Container} *)

type 'a container


(** {1 Media} *)

type audio
type video
type subtitle


(** {1 Format} *)

type ('line, 'media) format


(** {1 Frame} *)

type 'media frame


(** {1 Exception} *)

(** A failure occured (with given explanation). *)
exception Failure of string


(** {9 Timestamp} *)

(** Formats for time. *)
module Time_format : sig

  (** Time formats. *)
  type t = [
    | `second
    | `millisecond
    | `microsecond
    | `nanosecond
  ]
end

(** Return the time base of FFmpeg. *)
val time_base : unit -> int64



(** {5 Audio utilities} *)

(** Formats for channels layouts. *)
module Channel_layout : sig

  (** Channel layout formats. *)
  type t = Channel_layout.t
end

(** Formats for audio samples. *)
module Sample_format : sig

  (** Audio sample formats. *)
  type t = Sample_format.t

  (** Return the name of the sample format. *)
  val get_name : t -> string
end


(** {5 Video utilities} *)

(** Formats for pixels. *)
module Pixel_format : sig

  (** Pixels formats. *)
  type t = Pixel_format.t

  (** Return the number of bits of the pixel format. *)
  val bits : (*?padding:bool ->*) t -> int
end

module Video : sig
  type data = (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
  type planes = (data * int) array

  val create_frame : int -> int -> Pixel_format.t -> video frame
  (** [Avutil.Video.create_frame w h pf] create a video frame with [w] width, [h] height and [pf] pixel format. @raise Failure if the allocation failed. *)

  val frame_get_linesize : video frame -> int -> int
  (** [Avutil.Video.frame_get_linesize vf n] return the line size of the [n] plane of the [vf] video frame. @raise Failure if [n] is out of boundaries. *)

  val copy_frame_to_planes : video frame -> planes
  (** [Avutil.Video.copy_frame_to_planes vf] copy the video frame [vf] data to fresh arrays. *)

  val copy_planes_to_frame : video frame -> planes -> unit
  (** [Avutil.Video.copy_planes_to_frame vf planes] copy the [planes] to the video frame [vf]. @raise Failure if the make frame writable operation failed or if the planes lines sizes and the frame lines sizes are different. *)

  val frame_visit : make_writable:bool -> (planes -> unit) -> video frame -> video frame
  (** [Avutil.Video.frame_visit ~make_writable:wrt f vf] call the [f] function with planes wrapping the [vf] video frame data. The make_writable:[wrt] parameter must be set to true if the [f] function writes in the planes. Access to the frame through the planes is safe as long as it occurs in the [f] function and the frame is not sent to an encoder. The same frame is returned for convenience. @raise Failure if the make frame writable operation failed. *)
end


(** {5 Subtitle utilities} *)

module Subtitle : sig

  val time_base : unit -> int64
  (** Return the time base for subtitles. *)

  val create_frame : float -> float -> string list -> subtitle frame
  (** [Avutil.Subtitle.create_frame start end lines] create a subtitle frame from [lines] which is displayed at [start] time and hidden at [end] time in seconds. @raise Failure if the allocation failed. *)

  val frame_to_lines : subtitle frame -> (float * float * string list)
  (** Convert subtitle frame to lines. The two float are the start and the end dislpay time in seconds. *)
end
