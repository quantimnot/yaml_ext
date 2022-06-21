import
  std/[streams, strutils],
  pkg/yaml
export yaml except dump, load

proc constructObject*(
        s: var YamlStream, c: ConstructionContext, result: var uint64)
        {.raises: [YamlConstructionError, YamlStreamError].} =
    constructScalarItem(s, item, uint64):
        result = uint64(item.scalarContent.parseBiggestUInt)


when declared(times.DateTime) and declared normalDateTimeFormat:
  setTag(DateTime, Tag("!DateTime"))
  proc constructObject*[T: DateTime](
          s: var YamlStream, c: ConstructionContext, result: var T)
          {.raises: [YamlConstructionError, YamlStreamError].} =
      constructScalarItem(s, item, DateTime):
          result = times.parse(item.scalarContent, normalDateTimeFormat, normalTimezone)
  
  
  proc representObject*[T: DateTime](value: T, ts: TagStyle, c: SerializationContext, tag: Tag) {.raises: [].} =
    c.put(scalarEvent(value.format(normalDateTimeFormat), tag, yAnchorNone))


proc writeYaml*[T](s: string | Stream, i: T) =
  when s is Stream:
    yaml.dump(i, s,
      tagStyle = tsNone,
      anchorStyle = asTidy,
      options = defineOptions(style = psDefault, outputVersion = ovNone),
      @[]
    )
    streams.write(s, '\n')
  else:
    writeFile s:
      yaml.dump(i,
        tagStyle = tsNone,
        anchorStyle = asTidy,
        options = defineOptions(style = psDefault, outputVersion = ovNone),
        @[]
      )


proc readYaml*[T](s: string | Stream, o: var T) =
  yaml.load(s, o)
