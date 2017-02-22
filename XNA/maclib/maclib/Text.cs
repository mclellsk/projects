using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;

namespace maclib
{
    public class Text
    {
        string _text = "";
        SpriteFont _font;
        Vector2 _position;
        Color _color;
        Rectangle _textView;
        Vector2 _stringSize;
        List<string> textBuffer = new List<string>();

        public Text(string text, SpriteFont font, Color color, Vector2 position, Rectangle textView)
        {
            _text = text;
            _font = font;
            _position = position;
            _color = color;
            _textView = textView;
            _stringSize = _font.MeasureString(_text);
        }


        //Breaks apart a string into a formatted (word-wrapped) queue of strings.
        private List<string> formatText()
        {
            int currentChar = 0;
            while (currentChar != (_text.Length))
            {
                string buffer = "";
                for (int i = currentChar; i < _text.Length; i++)
                {
                    if (_font.MeasureString(buffer).X < _textView.Width)
                        buffer += _text[i];
                    else
                    {
                        currentChar = i+1;
                        break;
                    }
                }
                textBuffer.Add(buffer);
            }
            return textBuffer;
        }

        public void Draw(SpriteBatch spriteBatch)
        {
            spriteBatch.DrawString(_font, _text, new Vector2(_position.X, _position.Y), _color);
            /*
            formatText();
            int j = 0;
            for (int i = 0; i < (textBuffer.Count - 1); i++)
            {
                if (j < _textView.Height)
                {
                    spriteBatch.DrawString(_font, textBuffer.ElementAt(i), new Vector2 (_position.X, _position.Y+(j*_font.MeasureString(_text).Y)), _color);
                    j++;
                }
                else
                    break;
            }
             */
        }


    }
}
