# 🚀 G-Weather Deployment Guide

## Prerequisites

1. **Weather API Key**: Sign up at [weatherapi.com](https://www.weatherapi.com/) to get a free API key
2. **Gmail App Password**: Set up Gmail App Password for email functionality
3. **GitHub Account**: For repository hosting
4. **Vercel Account**: Sign up at [vercel.com](https://vercel.com/)

## 📋 Step-by-Step Deployment

### Step 1: Prepare Environment Files

1. Copy `env.example` to `.env`:
   ```bash
   cp env.example .env
   ```

2. Fill in your actual values in `.env`:
   ```env
   WEATHER_API_KEY=your_actual_api_key_here
   WEATHER_API_BASE_URL=https://api.weatherapi.com/v1
   EMAIL_BACKEND_URL=https://your-backend.vercel.app
   APP_NAME=G-Weather
   APP_URL=https://your-app.vercel.app
   ```

3. Copy `backend/env.example` to `backend/.env`:
   ```bash
   cp backend/env.example backend/.env
   ```

4. Fill in backend environment variables:
   ```env
   GMAIL_USER=your-email@gmail.com
   GMAIL_APP_PASSWORD=your_gmail_app_password
   PORT=3000
   APP_NAME=G-Weather
   APP_URL=https://your-app.vercel.app
   FRONTEND_URL=https://your-app.vercel.app
   FROM_EMAIL=your-email@gmail.com
   FROM_NAME=G-Weather Team
   ```

### Step 2: Deploy Backend First

1. Create a separate GitHub repository for the backend
2. Copy the `backend/` folder contents to the new repository
3. Push to GitHub
4. Deploy to Vercel:
   - Go to [vercel.com](https://vercel.com/)
   - Click "New Project"
   - Import your backend repository
   - Add environment variables in Vercel dashboard
5. Note the deployed backend URL

### Step 3: Deploy Frontend

1. Update `EMAIL_BACKEND_URL` in your frontend `.env` with the backend URL
2. Push your main repository to GitHub
3. Deploy to Vercel:
   - Import your main repository
   - Vercel will automatically detect the `vercel.json` configuration
   - Add environment variables in Vercel dashboard:
     - `WEATHER_API_KEY`
     - `WEATHER_API_BASE_URL`
     - `EMAIL_BACKEND_URL`

### Step 4: Configure Environment Variables in Vercel

**Frontend Environment Variables:**
- `WEATHER_API_KEY`: Your Weather API key
- `WEATHER_API_BASE_URL`: https://api.weatherapi.com/v1
- `EMAIL_BACKEND_URL`: Your deployed backend URL

**Backend Environment Variables:**
- `GMAIL_USER`: Your Gmail address
- `GMAIL_APP_PASSWORD`: Your Gmail App Password
- `PORT`: 3000
- `APP_NAME`: G-Weather
- `FROM_EMAIL`: Your Gmail address
- `FROM_NAME`: G-Weather Team

## 🔧 Build Commands

The deployment is configured in `vercel.json`:

**Frontend:**
- Install: `flutter pub get && dart run build_runner build --delete-conflicting-outputs`
- Build: `flutter build web --release --web-renderer canvaskit`
- Output: `build/web`

**Backend:**
- Node.js serverless function
- Entry point: `server.js`

## 🌐 Alternative Deployment Options

### Netlify
1. Connect GitHub repository
2. Build command: `flutter build web --release`
3. Publish directory: `build/web`
4. Add environment variables in Netlify dashboard

### Firebase Hosting
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize: `firebase init hosting`
4. Build: `flutter build web --release`
5. Deploy: `firebase deploy`

## 🔍 Troubleshooting

### Common Issues:

1. **Build fails**: Make sure all dependencies are installed
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **API calls fail**: Check environment variables are set correctly

3. **Email not working**: Verify Gmail App Password is correct

4. **CORS errors**: Backend should handle CORS automatically

### Logs:
- Check Vercel function logs in the dashboard
- Use browser developer tools for frontend debugging

## 📱 Testing

After deployment:
1. Test weather data loading
2. Test location search
3. Test email subscription functionality
4. Check responsive design on different devices

## 🔐 Security Notes

- Never commit `.env` files to version control
- Use environment variables for all sensitive data
- Regularly rotate API keys and passwords
- Monitor usage to prevent API quota exceeded

## 📞 Support

If you encounter issues:
1. Check Vercel deployment logs
2. Verify all environment variables are set
3. Test API endpoints individually
4. Check browser console for errors

---

Happy deploying! 🎉
