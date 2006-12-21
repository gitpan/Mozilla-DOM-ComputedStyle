#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <mozilla/nsCOMPtr.h>
#include <mozilla/nsIDOMWindow.h>
#include <mozilla/dom/nsIDOMViewCSS.h>
#include <mozilla/string/nsString.h>
#include <mozilla/nsIDOMCSSStyleDeclaration.h>

static SV *wrap_unichar_string(const PRUnichar *uni_str) {
	const char * u8str;
	NS_ConvertUTF16toUTF8 utf8(uni_str);

	u8str = utf8.get();
	return newSVpv(u8str, 0);
}


MODULE = Mozilla::DOM::ComputedStyle		PACKAGE = Mozilla::DOM::ComputedStyle		

SV *
Get_Computed_Style_Property(win, elem, pname)
	SV *win;
	SV *elem;
	const char *pname;
	INIT:
		nsCOMPtr<nsIDOMCSSStyleDeclaration> comp_style;
		nsIDOMWindow *window;
		nsIDOMViewCSS *w = 0;
		nsresult rv;
		nsString nspn, ret;
		SV *res = 0;
	CODE:
		window = INT2PTR(nsIDOMWindow *, SvIV(SvRV(win)));
		window->QueryInterface(NS_GET_IID(nsIDOMViewCSS), (void **) &w);
		if (!w)
			goto done;

		w->GetComputedStyle(INT2PTR(nsIDOMElement *, SvIV(SvRV(elem)))
				 , EmptyString()
				 , getter_AddRefs(comp_style));
		w->Release();
		if (!comp_style)
			goto done;

		CopyUTF8toUTF16(pname, nspn);
		rv = comp_style->GetPropertyValue(nspn, ret);
		if (NS_FAILED(rv))
			goto done;

		res = wrap_unichar_string(ret.get());
done:
		if (!res)
			XSRETURN_UNDEF;

		RETVAL = res;
	OUTPUT:
		RETVAL
