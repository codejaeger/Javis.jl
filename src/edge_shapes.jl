function edge_shape(shape::Symbol=:line, clip::Bool = false; center_offset::Real = 3, end_offsets::Tuple{Real, Real} = (0, 0), width::Real = 2, dash::String = "solid")
    opts = Dict{Symbol,Any}()
    opts[:shape] = shape
    opts[:clip] = clip
    opts[:linewidth] = width
    opts[:dash] = dash
    draw = (video, object, frame; shape=shape, p1=O, p2=O, loop=false, self_loop=false, kwargs...) -> begin
        setline(width)
        setdash(dash)
        if frame <= first(get_frames(object))+2
            return
        end
        if self_loop
            # Need to find out where to draw the edge without clutter
        elseif loop || shape == :curved
            center_pt = Luxor.perpendicular((p1+p2)/2, p1, center_offset)
            c, r = center3pts(p1, center_pt, p2)
            angles = slope(c, p1), slope(c, p2)
            angle_offsets = end_offsets./r
            new_angles = angles .+ (angle_offsets[1], -angle_offsets[2])
            Luxor.arc(c, r, new_angles..., clip ? :clip : :stroke)
            outline = [p1, center_pt, p2]
        else
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
