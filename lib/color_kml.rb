# By: Jori Hardman
# Last Modified: April 4, 2010
# color-lines.rb takes a Supermap kml and colors the lines depending on either
# dna mutations or character states.
# modified-by: ttreseder
# notes: this was originally a ruby script.  Now slightly refactored and modified
# to run in supramap.

module ColorKML

  #----------------------------Function Definitions------------------------------#
  #
  #buildStyles uses each value/color pair in colorHash to define a StyleMap
  #to be used for the kml's corresponding Placemarks.  It adds these to styles.
  #
  def buildStyles(colorHash)
    styles = ""
    colorHash.each do |key, value|
      text = <<-STYLE
  <Style id="#{key}a">
    <IconStyle>
      <scale>0.35</scale>
      <Icon><href>http://supramap.osu.edu/supramap/images/circle.png</href></Icon>
    </IconStyle>
    <LabelStyle><scale>0</scale></LabelStyle>
    <LineStyle>
      <width>1.5</width>
      <color>#{value}</color>
    </LineStyle>
  </Style>
  <Style id="#{key}b">
    <IconStyle>
      <scale>0.95</scale>
      <Icon><href>http://supramap.osu.edu/supramap/images/circle.png</href></Icon>
    </IconStyle>
    <LabelStyle><scale>1</scale></LabelStyle>
    <LineStyle>
      <width>4</width>
      <color>#{value}</color>
    </LineStyle>
  </Style>
  <StyleMap id="#{key}">
    <Pair><key>normal</key><styleUrl>##{key}a</styleUrl></Pair>
    <Pair><key>highlight</key><styleUrl>##{key}b</styleUrl></Pair>
  </StyleMap>
      STYLE
      styles << text
    end
    return styles
  end

  #
  #recursively checks Ancestors for a style
  #
  def checkAncestors(name, placeHash)
    values = placeHash[name]
    style = "00"
    if values == nil
      style = "00"
    elsif values[1] != nil
      style = values[1]
    elsif values[0] != nil
      style = checkAncestors(values[0], placeHash)
    else
      style = "00"
    end
    return style
  end

  #
  #recursively checks Descendants for a style
  #
  def checkDescendants(name, placeHash)
    values = placeHash[name]
    style = "00"
    if values == nil
      style = "00"
    elsif values[3] != nil
      style = values[3]
    elsif values[2] != []
      values[2].each do |cur|
        style = checkDescendants(cur, placeHash)
        break if style != "00"
      end
    else
      style = "00"
    end
    return style
  end

  #
  #getStyle finds a placemark's style by recursively checking its ancestors and descendants
  #
  def getStyle(name, placeHash)
    values = placeHash[name]
    style = "00"
    if values == nil
      style = "00"
    elsif values[1] != nil
      style = values[1]
    else
      style = checkAncestors(name, placeHash)
      style = checkDescendants(name, placeHash) if style == "00"
    end
    placeHash[name][1] = style
    return style
  end

  #
  #The function goes through each Placemark in the places array, and adds their
  #name and descendant value/ancestor to the placeHash
  #
  def buildPlaceHash(places, dna_align)
    placeHash = {}
    places.each do |placemark|
      if placemark =~ /id="pm_(.+)"><visibility><\/visibility>/
        placeName = $1
        if dna_align != nil
          if placemark =~ /:#{dna_align}<\/td>\n<td align="left" bgcolor="#E1E1E1"><font size="\+1">(.)<\/font>/
            ancVal = $1
          else
            ancVal = nil
          end
          if placemark =~ /:#{dna_align}<\/td>\n.*\n.*\n<td align="left" bgcolor="#FFFFFF"><font size="\+1">(.)<\/font>/
            desVal = $1
          else
            desVal = nil
          end
        else
          if placemark =~ /<td align="left" bgcolor="#FFFFFF"><font size="\+1">(.).*<\/font>/
            desVal = $1
          else
            desVal = nil
          end
          if placemark =~ /<td align="left" bgcolor="#E1E1E1"><font size="\+1">(.).*<\/font>/
            ancVal = $1
          else
            ancVal = nil
          end
        end
        descendants = []
        placemark.scan(/Descendant:<\/font>\n<\/td>\n<td><a href=".+">(.+)<\/a>/).each { |cur|
          descendants << cur[0]
        }
        if placemark =~ /Ancestor:<\/font>\n<\/td>\n<td><a href=".+">(.+)<\/a>/
          ancestor = $1
        else
          ancestor = nil
        end
        placeHash[placeName] = [ancestor, desVal, descendants, ancVal]
      end
    end
    placeHash["root"][1] = getStyle("root", placeHash)
    return placeHash
  end

  #
  #writeKml goes through places a second time, but this time, if the
  #place is in the placeHash, it sets the style of Placemark to the corresponding
  #style, and removes old styling tags and ids
  #
  def build_kml_str(places, placeHash)
    ret_str = ""
    places.each do |cur|
      if cur =~ /<LineStyle id="ls_(.+)"><color>FFffffff<\/color>/
        style = getStyle($1, placeHash)
        output = cur.sub(/<styleUrl>.+<\/styleUrl>/, "<styleUrl>##{style}</styleUrl>")
        output = output.sub(/<Placemark id=".+">/, "<Placemark>")
        output = output.sub(/<LineStyle id=".+"><color>FFffffff<\/color>\n<\/LineStyle>/, "")
        output = output.sub(/<Point id=".+">/, "<Point>")
        ret_str << "<Placemark#{output}"
      else
        ret_str << "<Placemark#{cur}"
      end
    end
    ret_str
  end

  def color_kml(orig_kml_str, *dna_align)
    if dna_align.empty?
      colorHash = {"0"=>"FF666666", "1"=>"FF0000FF", "2"=>"FF0099FF", "3"=>"FF00FFFF", "4"=>"FF00FF00",
                   "5"=>"FFFF0000", "6"=>"FFFFFF00", "7"=>"FF666600", "8"=>"FF660066", "9"=>"FFFF00FF"}
    else
      colorHash = {"A"=>"FF0000FF", "G"=>"FF00FF00", "C"=>"FFFF0000", "T"=>"FF660066", "U"=>"FF660066"}
    end

    places = orig_kml_str.split(/<Placemark/)

    #get a string of styles for the top of the kml
    styles = buildStyles(colorHash)

    #insert the new styles into the kml
    places[0].insert(places[0].index(/<Folder><name>1<\/name>/), styles)

    #replace the default style to have semi-transparent lines so colors show though
    places[0] = places[0].sub(/<LineStyle>/, "<LineStyle><color>80FFFFFF</color>")


    colored_kml_str = ""

    #write the beginning of the kml
    colored_kml_str << places[0]

    #remove the beginning of the kml from places
    places.delete_at(0)

    #write the rest of the kml
    colored_kml_str << build_kml_str(places, buildPlaceHash(places, dna_align[0]))
  end

end