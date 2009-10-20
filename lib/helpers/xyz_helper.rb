module Helpers::XYZHelper
  def xyz(*a)
    if a.length == 1 then
      if a[0].kind_of? Array then a[0]
      else
        if a[0].respond_to? :z then [a[0].x, a[0].y, a[0].z]
        else [a[0].x, a[0].y]  
        end
      end
    else a
    end
  end
end
