module KmToLong
  extend self
  include Math
  R = 6_371 #km
  def coord_to_km(coord1, coord2)
    lat1 = deg_to_rad(coord1.lat)
    lat2 = deg_to_rad(coord2.lat)
    dlat = deg_to_rad(coord2.lat - coord1.lat)
    dlng = deg_to_rad(coord2.lng - coord1.lng)

    a = sin(dlat/2)**2 + sin(dlng/2)**2 * cos(lat1) * cos(lat2)
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    R*c
  end

  def km_per_one_lng(coord)
    coord1 = coord
    coord2 = coord.dup
    coord2.lng += 1
    coord_to_km(coord1, coord2)
  end

  def km_per_one_lat
    coord1 = Struct.new(:lat, :lng).new(10,10)
    coord2 = coord1.dup
    coord2.lat+=1
    coord_to_km(coord1, coord2)
  end

  def km_to_lng(km, coord)
    km / km_per_one_lng(coord)
  end

  def deg_to_rad(num)
    num * PI / 180
  end
end
