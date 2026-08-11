module TranslationHelper
  # Demo-pragmatic translation: English strings in the views are the source,
  # GermanDictionary maps them 1:1. Unknown strings fall back to English, so a
  # missing entry can never break a page. Interpolation via %{name} placeholders.
  def dt(text, **args)
    template = I18n.locale == :de ? GermanDictionary::DICT.fetch(text, text) : text
    args.each { |key, value| template = template.gsub("%{#{key}}", value.to_s) }
    template
  end
end
