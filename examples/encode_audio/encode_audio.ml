open FFmpeg
module CL = Avutil.Channel_layout
module Resampler = Swresample.Make (Swresample.FloatArray) (Swresample.Frame)

let pi = 4.0 *. atan 1.0
let rate = 44100

let () =
  if Array.length Sys.argv < 3 then (
    Printf.eprintf "Usage: %s <output file> <codec name>\n" Sys.argv.(0);
    exit 1
  );
  let codec_id = Avcodec.Audio.find_by_name Sys.argv.(2)
  in
  let rsp = Resampler.to_codec CL.CL_mono rate codec_id CL.CL_stereo rate
  in
  let dst = Av.open_output Sys.argv.(1)
  in
  let sid = Av.new_audio_stream ~codec_id CL.CL_stereo rate dst
  in
  let c = (2. *. pi *. 440.) /. (float_of_int rate) in

  for i = 0 to 200 do
    Array.init 1024 (fun t -> sin(float_of_int(t + (i * 1024)) *. c))
    |> Resampler.convert rsp
    |> Av.write_audio_frame dst sid;
  done;

  Av.close_output dst;
  Gc.full_major ()