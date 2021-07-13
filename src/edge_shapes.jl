function edge_shape(shape::Symbol=:line, clip::Bool = false; center_offset::Real = 3, end_offsets::Tuple{Real, Real} = (0, 0), width::Real = 2, dash::String = "solid", direction=rand()*2*pi)
    opts = Dict{Symbol,Any}()
    opts[:shape] = shape
    opts[:clip] = clip
    opts[:linewidth] = width
    opts[:dash] = dash
    opts[:direction] = Point(cos(direction), sin(direction))
    draw = (video, object, frame; shape=shape, p1=O, p2=O, self_loop=false, direction=direction, from_node_bbx=(O, O), to_node_bbx=(O, O), kwargs...) -> begin
        setline(width)
        setdash(dash)
        if frame <= first(get_frames(object))+2
            return
        end
        # Calculate edge segment outside of node boundaries
        _, ip1, ip2 = intersectionlinecircle(p1, p2, p1, distance(O, (from_node_bbx[2]-from_node_bbx[1])/2))
        _p1 = ispointonline(ip1, ip2, (p1+p2)/2; extended=false) ? ip1 : ip2
        _, ip1, ip2 = intersectionlinecircle(p1, p2, p2, distance(O, (to_node_bbx[2]-to_node_bbx[1])/2))
        _p2 = ispointonline(ip1, ip2, (p1+p2)/2; extended=false) ? ip1 : ip2
        if self_loop
            r = max((from_node_bbx[2]-from_node_bbx[1])/2..., center_offset)
            c = p1 + r * direction
            # Might replace by a clipping region to remove the extra edge remnants appearing inside a node
            # pt1, pt2 = intersectioncircleboundingbox(c, r, from_node_bbx...)
            # A temporary solution unless intersectioncircleboundingbox is fixed
            _, pt1, pt2 = intersectioncirclecircle(c, r, p1, distance(O, (from_node_bbx[2]-from_node_bbx[1])/2))
            pt1, pt2 = isarcclockwise(c, pt1, pt2) ? (pt1, pt2) : (pt2, pt1)
            angles = slope(c, pt2), slope(c, pt1)
            angle_offsets = end_offsets./r
            new_angles = angles .+ (angle_offsets[1], -angle_offsets[2])
            Luxor.arc(c, r, new_angles..., clip ? :clip : :stroke)
            outline = [p1, c, p2]
        elseif shape == :curved
            p1, p2 = _p1, _p2
            center_pt = Luxor.perpendicular((p1+p2)/2, p1, center_offset)
            c, r = center3pts(p1, center_pt, p2)
            angles = slope(c, p1), slope(c, p2)
            angle_offsets = end_offsets./r
            new_angles = angles .+ (angle_offsets[1], -angle_offsets[2])
            Luxor.arc(c, r, new_angles..., clip ? :clip : :stroke)
            outline = [p1, c, p2]
        else
            p1, p2 = _p1, _p2
            d = Luxor.distance(p1, p2)
            t1 = end_offsets[1]/d
            t2 = (d-end_offsets[2])/d
            new_p1 = t1*p1 + (1-t1)*p2
            new_p2 = t2*p1 + (1-t2)*p2
            line(new_p1, new_p2, clip ? :clip : :stroke)
            outline = [p1, p2]
        end
        object.meta.opts[:outline] = outline
    end
    return opts, draw
end

function edge_style()
end

function edge_arrow()
end

function edge_label()
end

function intersectioncircleboundingbox(c::Point, radius::Real, upperleft::Point, lowerright::Point)
    # Find the closest corner of box to the center of the circle
    px = abs(lowerright[1] - c[1]) < abs(upperleft[1] - c[1]) ? lowerright[1] : upperleft[1]
    py = abs(lowerright[2] - c[2]) < abs(upperleft[2] - c[2]) ? lowerright[2] : upperleft[2]
    # Find the other 2 corner points joining this point
    o1 = Point(upperleft[1]+lowerright[1]-px, py)
    o2 = Point(px, upperleft[2]+lowerright[2]-py)
    # Calculate intersection points
    nints, ip1, ip2 = zip(intersectionlinecircle.(Point(px, py), [o1, o2], c, radius)...)
    p = Point(px, py)
    intersection_points = ispointonline.(ip1, [p, p], [o1, o2]; extended=false).*ip1 + ispointonline.(ip2, [p, p], [o1, o2]; extended=false).*ip2
    # throw(ErrorException("$nints, $ip1, $ip2, $intersection_points"))
    return intersection_points
end