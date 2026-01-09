# 🌐 How to Add CareerWise Chatbot to Your Website

Your chatbot is live! Here's how to add it to your website or Squarespace site.

---

## 🎯 Quick Integration (Any Website)

### For Any HTML Website

1. **Copy the widget code:**
   - Open `widget_embed.html` 
   - Copy the entire code block

2. **Paste before `</body>` tag:**
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <title>Your Website</title>
   </head>
   <body>
       <!-- Your website content here -->
       
       <!-- Paste the widget code here, before </body> -->
       
   </body>
   </html>
   ```

3. **Update the API URL** (if needed):
   - Find this line in the widget code:
   ```javascript
   const API_URL = 'https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/chat';
   ```
   - Make sure it matches your deployed URL

4. **Save and test!**

---

## 🎨 Squarespace Integration

### Method 1: Code Injection (Recommended)

1. **Go to your Squarespace site editor**
   - Login to your Squarespace account
   - Go to **Settings** → **Advanced** → **Code Injection**

2. **Add to Footer Code:**
   - Click on **Footer** tab
   - Paste the widget code from `widget_embed.html`
   - **Important:** Make sure to paste it exactly as is (including the script tags)
   - Click **Save**

3. **Update API URL:**
   - In the pasted code, find:
   ```javascript
   const API_URL = 'https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/chat';
   ```
   - Make sure this matches your deployed URL

4. **Publish your site:**
   - Click **Save** in the code injection page
   - The widget will appear on all pages automatically!

### Method 2: Code Block (Single Page)

If you only want it on specific pages:

1. **Edit the page** where you want the chatbot
2. **Add a Code Block:**
   - Click **+** (Add Block)
   - Select **Code**
3. **Paste the widget code**
4. **Update API URL** (same as above)
5. **Save and publish**

**Note:** With Code Block, the chatbot will only appear on that specific page.

---

## 🎯 WordPress Integration

### Method 1: Theme Footer (Recommended)

1. **Go to Appearance → Theme Editor**
2. **Select `footer.php`** (or your theme's footer file)
3. **Paste the widget code before `</body>`**
4. **Update API URL**
5. **Save**

### Method 2: Plugin (Easy)

1. **Install "Insert Headers and Footers" plugin**
2. **Go to Settings → Insert Headers and Footers**
3. **Paste code in Footer section**
4. **Update API URL**
5. **Save**

---

## ⚙️ Customization Options

### Change Colors

Find these lines in the widget code and change the colors:

```javascript
// Change gradient colors (lines with #667eea and #764ba2)
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
// Change to your brand colors, e.g.:
background: linear-gradient(135deg, #your-color-1 0%, #your-color-2 100%);
```

### Change Position

To move the button to bottom-left:

```css
#careerwise-chatbot-widget {
    right: auto;  /* Remove right positioning */
    left: 20px;   /* Add left positioning */
}
```

### Change Button Text/Icon

Find this line:
```html
<button id="careerwise-chat-button">💬</button>
```

Change to:
```html
<button id="careerwise-chat-button">Chat</button>
<!-- Or use an icon from your icon library -->
```

### Change Welcome Message

Find this line:
```javascript
Hello! I'm here to answer questions about my career, skills, and experience. How can I help you?
```

Change to your custom message.

---

## ✅ Testing Checklist

After adding to your site:

- [ ] Widget appears on page (chat button in bottom-right)
- [ ] Clicking button opens chat window
- [ ] Can type and send messages
- [ ] Receives responses from chatbot
- [ ] Works on desktop
- [ ] Works on mobile
- [ ] No console errors (check with F12)

---

## 🐛 Troubleshooting

### Widget doesn't appear

**Solution:**
- Check that code is before `</body>` tag
- Verify no JavaScript errors in console (F12)
- Make sure API_URL is correct

### "Failed to fetch" errors

**Solution:**
- Check API URL is correct
- Verify your API is accessible: https://your-url.a.run.app/docs
- Check browser console for CORS errors

### Widget appears but doesn't work

**Solution:**
- Open browser console (F12)
- Look for JavaScript errors
- Verify API endpoint is responding
- Check network tab for failed requests

### Squarespace-specific issues

**Solution:**
- Make sure you pasted in **Code Injection** → **Footer** (not Header)
- Try clearing Squarespace cache
- Publish and preview your site
- Some themes may need slight CSS adjustments

---

## 📱 Mobile Responsiveness

The widget is mobile-responsive by default. On mobile:
- Button appears smaller (50px vs 60px)
- Chat window becomes full-screen
- Touch-friendly interface

---

## 🔒 Privacy & Security

- **API calls:** All messages go directly to your Cloud Run API
- **No data stored:** Message history is only in browser session
- **HTTPS:** Your API uses HTTPS (secure)
- **CORS:** Configured to allow your domain

---

## 🎨 Styling Tips

### Match Your Website Theme

1. **Extract your brand colors:**
   - Use your primary/secondary colors for the gradient
   - Match button colors to your site's CTA buttons

2. **Adjust font:**
   ```css
   font-family: 'Your Font', sans-serif;
   ```

3. **Match border radius:**
   ```css
   border-radius: 12px; /* Match your site's border radius */
   ```

---

## 📝 Example: Customized for Your Brand

```javascript
// Example customization
const API_URL = 'https://your-custom-domain.com/chat';

// Custom colors
background: linear-gradient(135deg, #your-primary-color 0%, #your-secondary-color 100%);

// Custom welcome message
Hello! I'm [Your Name], and I'd love to chat about opportunities. What would you like to know?
```

---

## 🚀 Next Steps

1. ✅ Add widget to your site
2. ✅ Test on desktop and mobile
3. ✅ Customize colors and styling
4. ✅ Update welcome message
5. ✅ Share your website!

---

## 📚 Resources

- **Your API Docs:** https://careerwise-chatbot-ftzbbbgsba-uc.a.run.app/docs
- **Squarespace Help:** https://support.squarespace.com/hc/en-us/articles/205815908-Using-code-injection
- **Widget Code:** See `widget_embed.html`

---

**🎉 Your chatbot is ready to go live on your website!**
