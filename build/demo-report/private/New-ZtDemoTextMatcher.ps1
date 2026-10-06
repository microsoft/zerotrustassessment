function New-ZtDemoTextMatcher {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Names
    )

    if (-not ('ZeroTrustAssessment.DemoTextMatcher' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Text;

namespace ZeroTrustAssessment
{
    public sealed class DemoTextMatcher
    {
        private sealed class Node
        {
            public readonly Dictionary<char, Node> Children = new Dictionary<char, Node>();
            public string Name;
        }

        private readonly Node root = new Node();

        public DemoTextMatcher(string[] names)
        {
            foreach (string name in names)
            {
                if (name.Length < 3) continue;
                Node node = root;
                foreach (char character in name)
                {
                    char key = Char.ToUpperInvariant(character);
                    Node next;
                    if (!node.Children.TryGetValue(key, out next))
                    {
                        next = new Node();
                        node.Children.Add(key, next);
                    }
                    node = next;
                }
                node.Name = name;
            }
        }

        private static bool IsWord(char value)
        {
            return Char.IsLetterOrDigit(value) || value == '_';
        }

        private string Match(string text, int start, out int length)
        {
            length = 0;
            if (start > 0 && IsWord(text[start - 1])) return null;
            Node node = root;
            string name = null;
            for (int index = start; index < text.Length; index++)
            {
                Node next;
                if (!node.Children.TryGetValue(Char.ToUpperInvariant(text[index]), out next)) break;
                node = next;
                if (node.Name != null && (index + 1 == text.Length || !IsWord(text[index + 1])))
                {
                    name = node.Name;
                    length = index - start + 1;
                }
            }
            return name;
        }

        public string Replace(string text, Dictionary<string, string> replacements)
        {
            StringBuilder output = new StringBuilder(text.Length);
            int unchangedStart = 0;
            for (int index = 0; index < text.Length;)
            {
                int length;
                string name = Match(text, index, out length);
                if (name == null) { index++; continue; }
                output.Append(text, unchangedStart, index - unchangedStart);
                output.Append(replacements[name]);
                index += length;
                unchangedStart = index;
            }
            if (unchangedStart == 0) return text;
            output.Append(text, unchangedStart, text.Length - unchangedStart);
            return output.ToString();
        }

        public int CountMatches(string text)
        {
            int count = 0;
            for (int index = 0; index < text.Length;)
            {
                int length;
                if (Match(text, index, out length) == null) { index++; continue; }
                count++;
                index += length;
            }
            return count;
        }

        public string[] MatchNames(string text)
        {
            List<string> names = new List<string>();
            for (int index = 0; index < text.Length;)
            {
                int length;
                string name = Match(text, index, out length);
                if (name == null) { index++; continue; }
                names.Add(name);
                index += length;
            }
            return names.ToArray();
        }
    }
}
'@
    }
    return [ZeroTrustAssessment.DemoTextMatcher]::new($Names)
}
