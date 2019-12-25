shader_type canvas_item;

uniform vec4 belt_color;
uniform vec4 kimono_color1;
uniform vec4 kimono_color2;

void fragment() 
{
    vec4 col = texture(TEXTURE, UV).rgba;
	if ((col.r>0.85)&&(col.g==0.0)&&(col.a==1.0))
	{
		if (belt_color.a>0.0)
		{
			col = belt_color;
		}
	}
	if ((col.r>0.8&&col.r<0.9)&&(col.g>0.8&&col.g<0.9)&&(col.b>0.8&&col.b<0.9)&&(col.a==1.0))
	{
		if (kimono_color1.a>0.0)
		{
			col = kimono_color1;
		}
	}
	if ((col.r>0.5&&col.r<0.6)&&(col.g>0.5&&col.g<0.6)&&(col.b>0.5&&col.b<0.6)&&(col.a==1.0))
	{
		if (kimono_color2.a>0.0)
		{
			col = kimono_color2;
		}
	}
	COLOR = col;
}
