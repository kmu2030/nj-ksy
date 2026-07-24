name := "translator"

version := "0.11"

scalaVersion := "2.13.13"

libraryDependencies ++= Seq(
  "io.kaitai" %% "kaitai-struct-compiler" % "0.11",
  "com.github.scopt" %% "scopt" % "4.1.0"
)

mainClass := Some("io.kaitai.struct.testtranslator.Main")
