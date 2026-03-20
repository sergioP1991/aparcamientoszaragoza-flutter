# 🧪 RELEASE BUTTON - STEP-BY-STEP TESTING GUIDE

**Objetivo**: Verificar que el botón "Liberar Ahora" funciona correctamente después de aplicar los fixes

---

## 📋 BEFORE-TESTING CHECKLIST

Before you start testing, make sure:

- [ ] Applied FIX #1 to `RentalByHoursService.dart` (enhanced validation)
- [ ] Applied FIX #2 to `active_rentals_screen.dart` (enhanced error handling)
- [ ] Updated code in your IDE
- [ ] Executed `flutter pub get` (if dependencies changed)
- [ ] Not running the old app (close all Flutter windows)

---

## 🚀 QUICK START (5 minutes)

### Step 1: Start Fresh
```bash
cd /path/to/your/project
flutter clean
flutter pub get
flutter run -d chrome
```

**Expected**: App loads normally without errors

---

### Step 2: Check Current Active Rentals
1. Open app in Chrome
2. Navigate to **Perfil** (Profile)
3. Click **Mis Alquileres** (My Rentals)
4. Check if you have any active rentals listed
   - If YES: Go to Step 3
   - If NO: Go to "Create Test Rental" section below

---

### Step 3: Open Browser Console
1. Press **F12** to open Developer Tools
2. Go to **Console** tab
3. Leave it open - you'll watch logs here

**Expected Console Should Show**:
- App initialization logs
- No red errors (yet)

---

### Step 4: Click Release Button

**In Active Rentals List**:
1. Find a rental with status badge
2. Click blue button **"Liberar Ahora"** (Release Now)
3. A dialog appears asking for confirmation

**Expected Dialog**:
```
¿Deseas liberar la plaza?
[CANCELAR] [LIBERAR]
```

---

### Step 5: Confirm Release
1. Click **"LIBERAR"** button in dialog
2. Loading SnackBar appears: "Liberando plaza..."
3. Watch console for logs:

**Expected Logs in Console** (look for these in order):
```
🔑 [RENTAL_SERVICE] releaseRental() called with rentalId: abc123xyz...
✅ [RENTAL_SERVICE] rentalId format validated
✅ [RENTAL_SERVICE] User authenticated: [your-uid]
✅ [RENTAL_SERVICE] Documento encontrado en Firestore
✅ [RENTAL_SERVICE] Documentación complete
✅ [RENTAL_SERVICE] documentId verified: abc123xyz
✅ [RENTAL_SERVICE] Ownership verified: usuario propietario del rental
📊 [RENTAL_SERVICE] Actualizando estado en Firestore...
✅ [RENTAL_SERVICE] Estado actualizado a "liberado"
```

---

### Step 6: Check Result

**Success Case** ✅:
- Green SnackBar appears: "✅ Alquiler liberado. Total: €XX.XX"
- Rental disappears from the active list
- Loading dialog closes
- No red errors in console

**Failure Case** ❌:
- See red error in SnackBar
- Read the error message carefully
- Check console logs for where it failed
- Go to "Troubleshooting" section below

---

## 🧪 CREATE TEST RENTAL (If No Active Rentals)

### Step A: Find a Parking Slot
1. Go to **Home**
2. Click on any parking slot card
3. You should see a large detail screen

### Step B: Start Rental
1. Click **"Alquiler por Horas"** (Hourly Rental)
2. Select duration: e.g., **"2h"**
3. You'll see a breakdown:
   ```
   Base: €5.00
   Comisión: €0.45
   IVA: €1.14
   ────────
   Total: €6.59
   ```

### Step C: Choose Payment Method
1. Select **"Tarjeta"** (Card)
2. Click **"Confirmar Alquiler"** (Confirm Rental)

### Step D: Stripe Payment
1. Payment form appears
2. Use test card: **4242 4242 4242 4242**
3. Expiry: **12/25** (any future date)
4. CVC: **123** (any 3 digits)
5. Name: Any name
6. Click **"Pagar"** (Pay)

### Step E: Confirm Success
1. Green SnackBar: "✅ Pago confirmado y alquiler creado"
2. App navigates back to home
3. Click your profile → My Rentals
4. New active rental now shows in the list ✅

---

## 🔍 DETAILED TROUBLESHOOTING

### Scenario A: Red Error "❌ Error interno: documentId faltante"

**What it means**: 
You have an OLD rental record that was created before documentId tracking was added

**Solution**:
1. This is expected for old rentals
2. You need to run the migration Cloud Function (FIX #3)
3. Or manually update in Firestore:
   - Open Firebase Console
   - Go to Firestore
   - Find the rental document
   - Add field: `documentId` = `[document-id]` (copy-paste the document ID at top)
   - Save

**To Test Again**:
1. Close app completely
2. Refresh Firestore in console to confirm change
3. `flutter run -d chrome` again
4. Try release button again - should work now ✅

---

### Scenario B: Red Error "❌ Sesión expirada"

**What it means**: 
Your Firebase Auth session expired

**Solution**:
1. Close app
2. `flutter run -d chrome` again
3. Login fresh with your account
4. Try release button again

---

### Scenario C: Red Error "❌ El alquiler no fue encontrado"

**What it means**:
The rental document doesn't exist in Firestore (already deleted? corrupted?)

**Solution**:
1. But the rental is still showing in your list
2. This means the list is stale
3. Solution: First, refresh the active rentals page:
   - Click back to home
   - Click "My Rentals" again
   - The rental should disappear now

---

### Scenario D: Button Click, then Nothing Happens

**What it means**:
Service is silently failing before showing error

**Solution**:
1. Check console (F12 → Console tab)
2. Look for any RED errors
3. If you see red error log, copy it and check Scenarios A-C above
4. If NO red errors in console, then:
   - This is a network issue
   - Wait a few seconds and try again
   - Check your internet connection

---

### Scenario E: Button Works, Rental Disappears, But Green Message Says "Error"

**What it means**:
Weird state - release succeeded in database but UI message failed

**Solution**:
This is actually OK:
1. The rental WAS released (it disappeared)
2. Just the success message didn't appear
3. Go back to Perfil → Mis Alquileres
4. Confirm rental is gone ✅

---

## 📊 FIRESTORE VERIFICATION

### Method 1: Check documentId Field Presence

1. Open **Firebase Console**
2. Go to **Firestore Database**
3. Click **alquileres** collection
4. Pick any document with **estado** = **"activo"**
5. Scroll up to see all fields
6. Look for **"documentId"** field

**Expected**:
- Field exists
- Value matches the document ID shown at top (grey text)
- Example: Document ID is `abc123xyz`, documentId field value is `abc123xyz`

**If Missing**:
- This is the root cause - old record without documentId
- Run migration (FIX #3) OR manually add it

---

### Method 2: Check Estado Field Format

1. In same document, find **"estado"** field
2. Check the value

**Expected**:
- Value is exactly: `"liberado"` (lowercase, no enum prefix)
- NOT: `"EstadoAlquilerPorHoras.liberado"` (old format)

**Why**: New code saves as simple name "liberado"

---

## ✅ COMPLETE SUCCESS TEST

If all these pass, the fix is working correctly:

- [ ] Create new test rental (2 hours, €XX total)
- [ ] Stripe payment succeeds with green confirmation
- [ ] Navigate to Mis Alquileres
- [ ] New rental appears in active list
- [ ] Click "Liberar Ahora"
- [ ] Confirm in dialog
- [ ] See logs: "✅ documentId verified"
- [ ] See logs: "✅ Estado actualizado"
- [ ] Green SnackBar: "✅ Alquiler liberado"
- [ ] Rental DISAPPEARS from active list
- [ ] Close app and reopen → Rental still gone (persistent)

**If all pass**: ✅ FIX IS WORKING

---

## 📝 LOGS TO WATCH

### Good Logs (Release Successful)
```
🔑 [RENTAL_SERVICE] releaseRental() called with rentalId: pi_1H3yR2...
✅ [RENTAL_SERVICE] rentalId format validated
✅ [RENTAL_SERVICE] User authenticated: TK4jZ8qW2X...
📋 [RENTAL_SERVICE] Fetching Firestore document: pi_1H3yR2...
✅ [RENTAL_SERVICE] Documento encontrado en Firestore
🔄 [RENTAL_SERVICE] Deserializando documento...
✅ [RENTAL_SERVICE] Deserialización completa
✅ [RENTAL_SERVICE] documentId verified: pi_1H3yR2...
✅ [RENTAL_SERVICE] Ownership verified: usuario propietario del rental
🔑 [RENTAL_SERVICE] Actualizando estado en Firestore...
✅ [RENTAL_SERVICE] Estado actualizado a "liberado"
📊 [RENTAL_SERVICE] Resumen: 47 min usado, €4.93 cobrados
```

### Bad Logs (Release Failed)
```
🔑 [RENTAL_SERVICE] releaseRental() called with rentalId: null
❌ [RENTAL_SERVICE] ERROR: rentalId formato inválido: "null"
❌ [RENTAL_SERVICE] EXCEPTION en releaseRental(): rentalId is invalid: null
```

---

## 🎯 COMMON ISSUES & FIXES

| Issue | Cause | Fix |
|-------|-------|-----|
| Button doesn't respond at all | App crash or error | Check console for red errors |
| Red error about documentId | Old rental without documentId | Run migration (FIX #3) |
| Rental shows up again after refresh | Firestore update failed | Check Firestore Console > Audits for errors |
| Button says "Error" but rental is gone | UI lag but data updated | Check Firestore Console to verify it's gone |
| Can't create new rental | Payment failed | Try different test card (4000 0027 6000 3184 for decline test) |

---

## 📞 STILL HAVING ISSUES?

### Gather Debugging Info:

1. **Screenshot of the error message** (if any)
2. **Console logs** - Copy the red error line
3. **Firestore document ID** - The rental that's failing
4. **Recent actions** - What did you do right before?

Then check:
- [ ] RELEASE_BUTTON_COMPREHENSIVE_DIAGNOSIS.md (created earlier)
- [ ] This file (testing guide)
- [ ] Firestore Console for data state

---

## 🚀 NEXT STEPS AFTER SUCCESS

Once testing passes:

1. **Deploy to production** (Firebase Hosting)
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

2. **Monitor logs** (Firebase Console > Functions)
   - Watch for any new errors
   - Check release button usage patterns

3. **User communication** (Optional)
   - Let users know feature is fixed
   - Brief release notes

4. **Final verification**
   - Test on real device (Android/iOS)
   - Test with multiple user accounts
   - Test multiple releases in sequence

---

**Last Updated**: 6 March 2026  
**Testing Time**: ~15 minutes for complete verification  
**Difficulty**: Easy (just click buttons and watch logs)
