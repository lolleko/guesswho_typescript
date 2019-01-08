type GWLanguageTable = {[key: string]: string}

class GWLocalization {
    private defaultLocale = "en";
    private currentLocale: string;
    private locales: {[key: string]: GWLanguageTable};
    private static instance: GWLocalization;

    public get CurrentLocale(): string {
        return this.currentLocale;
    }; 

    public set CurrentLocale(newLocale: string) {
        if (this.IsLocale(newLocale)) {
            this.currentLocale = newLocale;
        }
    };

    constructor() {
        this.currentLocale = this.defaultLocale;
    }

    public IsLocale(locale: string): boolean {
        return this.locales[locale] != undefined;
    }

    public Translate(token: string): string {
        return this.locales[this.currentLocale][token] || this.locales[this.defaultLocale][token] || token;
    }

    public AddLanguage(locale: string, langTbl: GWLanguageTable) {
        this.locales[locale] = langTbl;
    }

    public GetLocaleList(): string[] {
        // TODO change to object.Keys()
        return table.GetKeys(this.locales) as string[];
    }

    public static GetInstance(): GWLocalization {
        if (!GWLocalization.instance) {
            GWLocalization.instance = new GWLocalization();
        }
        return GWLocalization.instance;
    }
}