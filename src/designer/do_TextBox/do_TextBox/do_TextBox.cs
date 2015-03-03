using doControlLib;
using doControlLib.tools;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace doUIViewDesign
{
    class do_TextBox : doComponentUIView
    {
        public override void DrawControl(int _x, int _y, int _width, int _height, Graphics g)
        {
            base.DrawControl(_x, _y, _width, _height, g);

            Rectangle _border = new Rectangle(_x, _y, this.CurrentModel.Width, this.CurrentModel.Height);
            Pen pen_border = new Pen(Color.Black);
            g.DrawRectangle(pen_border, _border);

            string _text = this.CurrentModel.GetPropertyValue("text");
            this.drawText(g, _text,
                _x, _y, this.CurrentModel.Width, this.CurrentModel.Height, StringFormatFlags.NoWrap, false, false);
        }

        protected override bool AllowTransparent
        {
            get
            {
                return false;
            }
        }
    }
}
